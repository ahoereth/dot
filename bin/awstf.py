#!/usr/bin/env python3
"""Script locating the cheapest AWS GPU compute spot instance for docker.

Usage:

    awstf.py --help
    eval "`awstf.py`"

"""
from argparse import ArgumentParser
from datetime import datetime, timedelta
from itertools import groupby
from operator import itemgetter

import boto3
import numpy as np

REGIONS = {
    'common': ['ap-south-1', 'eu-west-2', 'eu-west-1', 'ap-northeast-2',
               'ap-northeast-1', 'sa-east-1', 'ca-central-1', 'ap-southeast-1',
               'ap-southeast-2', 'eu-central-1', 'us-east-1', 'us-east-2',
               'us-west-1', 'us-west-2'],
    'p2.xlarge': ['us-east-1', 'us-east-2', 'us-west-2',
                  'eu-west-1', 'eu-central-1',
                  'ap-northeast-1', 'ap-southeast-1'],
    'p2.8xlarge': ['us-east-1', 'us-east-2', 'us-west-2',
                   'eu-west-1', 'eu-central-1',
                   'ap-northeast-1'],
    'p2.16xlarge': ['us-east-1', 'us-east-2', 'us-west-2',
                    'eu-west-1', 'eu-central-1'],
}


AMIS = {
    'us-east-1': {  # N. Virginia
        'p2.xlarge': 'ami-aeae1dd4',
        'p2.8xlarge': 'ami-aeae1dd4',
        'p2.16xlarge': 'ami-aeae1dd4',
    },
    'us-east-2': {  # Ohio
        'p2.xlarge': 'ami-fccae599',
        'p2.8xlarge': 'ami-fccae599',
        'p2.16xlarge': 'ami-fccae599',
    },
    'us-west-2': {  # Oregon
        'p2.xlarge': 'ami-e36abf9b',
        'p2.8xlarge': 'ami-e36abf9b',
        'p2.16xlarge': 'ami-e36abf9b',
    },
    'eu-west-1': {  # Ireland
        'p2.xlarge': 'ami-f8da7781',
        'p2.8xlarge': 'ami-f8da7781',
        'p2.16xlarge': 'ami-f8da7781',
    },
    'eu-central-1': {  # Frankfurt
        'p2.xlarge': 'ami-3fa62150',
        'p2.8xlarge': 'ami-3fa62150',
        'p2.16xlarge': 'ami-3fa62150',
    },
    'ap-northeast-1': {  # Tokyo
        'p2.xlarge': 'ami-39a8005f',
        'p2.8xlarge': 'ami-39a8005f',
    },
    'ap-southeast-1': {  # Singapore
        'p2.xlarge': 'ami-db440ab8',
    },
}


def build_command(ami=None, key_id=None, key_secret=None, userdata=None,
                  **launch_args):
    """Build docker-machine instance launch command."""
    cmd = '''docker-machine create {name} \\
        --driver amazonec2 \\
        --engine-install-url https://releases.rancher.com/install-docker/18.03.sh \\
        --amazonec2-region {region} \\
        --amazonec2-zone {zone} \\
        --amazonec2-instance-type {instance_type} \\
        --amazonec2-security-group {security_group} \\
        --amazonec2-request-spot-instance \\
        --amazonec2-spot-price {price_max:.4f} \\
        --amazonec2-root-size {size}
    '''.strip().format(**launch_args, size=32)
    # --engine-install-url https://test.docker.com \

    if userdata is not None:
        cmd += ' \\\n        --amazonec2-userdata {}'.format(userdata)

    # if ami is not None:
    #     cmd += ' \\\n        --amazonec2-ami {}'.format(ami)

    if key_id is not None and key_secret is not None:
        cmd += ' \\\n        --amazonec2-access-key {}'.format(key_id)
        cmd += ' \\\n        --amazonec2-secret-key {}'.format(key_secret)

    return cmd


def get_avg_price(instance_type, hours=5, key_id=None, key_secret=None):
    """Get up to date average price for a specific instance type."""
    print('# Searching for cheapest region...')
    kwargs = {'aws_access_key_id': key_id, 'aws_secret_access_key': key_secret}
    regions_key = instance_type if instance_type in REGIONS else 'common'
    regions = REGIONS[regions_key]
    prices = []
    for region in regions:
        client = boto3.client('ec2', region_name=region, **kwargs)
        zones = client.describe_availability_zones()
        zones = [zone['ZoneName'] for zone in zones['AvailabilityZones']]
        history = client.describe_spot_price_history(
            StartTime=datetime.today() - timedelta(hours=hours),
            EndTime=datetime.today(),
            InstanceTypes=[instance_type],
            ProductDescriptions=['Linux/UNIX'],
            Filters=[{'Name': 'availability-zone', 'Values': zones}],
        )
        history = history['SpotPriceHistory']
        grouper = itemgetter('AvailabilityZone')
        region_prices = []
        for zone, items in groupby(sorted(history, key=grouper), key=grouper):
            price = np.mean([float(i['SpotPrice']) for i in items])
            region_prices.append((zone, price))
        prices.append(sorted(region_prices, key=lambda t: t[1])[0])
        print('# {}: {:.4f}'.format(*prices[-1]))
    return sorted(prices, key=lambda t: t[1])


def main(machine_name, instance_type, security_group, max_price_overhead,
         hours, key_id, key_secret, userdata):
    """Find cheapest region and provide launch command."""
    averages = get_avg_price(instance_type, hours, key_id, key_secret)
    zone, price = averages[0]
    region = zone[:-1]
    cmd = build_command(
        name=machine_name,
        region=zone[:-1],
        zone=zone[-1],
        instance_type=instance_type,
        security_group=security_group,
        price_max=price + max_price_overhead,
        ami=AMIS[region].get(instance_type, None) if region in AMIS else None,
        key_id=key_id,
        key_secret=key_secret,
        userdata=userdata,
    )

    print('# Instances of type {instance_type} are cheapest in region {zone} '
          'with an average price of ${price:.4f} over the last {hours} hours.'
          .format(instance_type=instance_type, zone=zone, price=price,
                  hours=hours))
    print('# Issue the following command to launch a spot instance '
          'or call this script with')
    print('# eval "`awstf.py`" \n')
    print(cmd)


if __name__ == '__main__':
    ARGS = ArgumentParser()
    ARGS.add_argument('machine_name')
    ARGS.add_argument('-t', '--instance-type', default='p2.xlarge')
    ARGS.add_argument('-sg', '--security-group', default='docker-machine')
    ARGS.add_argument('--max-price-overhead', default=.1, type=float)
    ARGS.add_argument('--hours', default=5, type=float)
    ARGS.add_argument('--key-id')
    ARGS.add_argument('--key-secret')
    ARGS.add_argument('--userdata')
    main(**vars(ARGS.parse_args()))
