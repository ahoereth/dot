#!/usr/bin/env python3
"""Script locating the cheapest AWS GPU compute spot instance for docker."""
from argparse import ArgumentParser
from datetime import datetime, timedelta
from itertools import groupby
from operator import itemgetter

import boto3
import numpy as np


AMIS = {
    ('p2.xlarge', 'us-east-1'): 'ami-96982080',  # N. Virginia
    ('p2.xlarge', 'us-west-2'): 'ami-00fd6960',  # Oregon
    ('p2.xlarge', 'eu-west-1'): 'ami-71e4d817',  # Ireland
}


def build_command(ami=None, key_id=None, key_secret=None, **launch_args):
    """Build docker-machine instance launch command."""
    cmd = '''docker-machine create {name} \\
        --driver amazonec2 \\
        --amazonec2-region {region} \\
        --amazonec2-zone {zone} \\
        --amazonec2-instance-type {instance_type} \\
        --amazonec2-security-group {security_group} \\
        --amazonec2-request-spot-instance \\
        --amazonec2-spot-price {price_max:.4f} \\
        --amazonec2-root-size {size}
    '''.strip().format(**launch_args, size=32)

    if ami is not None:
        cmd += ' \\\n        --amazonec2-ami {}'.format(ami)

    if key_id is not None and key_secret is not None:
        cmd += ' \\\n        --amazonec2-access-key {}'.format(key_id)
        cmd += ' \\\n        --amazonec2-secret-key {}'.format(key_secret)

    return cmd


def get_avg_price(instance_type, hours=5, key_id=None, key_secret=None):
    """Get up to date average price for a specific instance type."""
    kwargs = {'aws_access_key_id': key_id, 'aws_secret_access_key': key_secret}
    useast1 = boto3.client('ec2', region_name='us-east-1', **kwargs)
    uswest2 = boto3.client('ec2', region_name='us-west-2', **kwargs)
    euwest1 = boto3.client('ec2', region_name='eu-west-1', **kwargs)
    clients = [useast1, uswest2, euwest1]

    prices = []
    for client in clients:
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
        for zone, items in groupby(sorted(history, key=grouper), key=grouper):
            price = np.mean([float(i['SpotPrice']) for i in items])
            prices.append((zone, price))
    return sorted(prices, key=lambda t: t[1])


def main(machine_name, instance_type, security_group, max_price_overhead,
         hours, key_id, key_secret):
    """Find cheapest region and provide launch command."""
    averages = get_avg_price(instance_type, hours, key_id, key_secret)
    zone, price = averages[0]
    ami = (instance_type, zone[:-1])

    print('# Instances of type {instance_type} are cheapest in region {zone} '
          'with an average price of ${price:.4f} over the last {hours} hours.'
          .format(instance_type=instance_type, zone=zone, price=price,
                  hours=hours))
    print('# Issue the following command to launch a spot instance '
          'or call this script with eval $(SCRIPT). \n')
    print(build_command(
        name=machine_name,
        region=zone[:-1],
        zone=zone[-1],
        instance_type=instance_type,
        security_group=security_group,
        price_max=price + max_price_overhead,
        ami=AMIS[ami] if ami in AMIS else None,
        key_id=key_id,
        key_secret=key_secret,
    ))


if __name__ == '__main__':
    ARGS = ArgumentParser()
    ARGS.add_argument('machine_name')
    ARGS.add_argument('-t', '--instance-type', default='p2.xlarge')
    ARGS.add_argument('-sg', '--security-group', default='docker-machine')
    ARGS.add_argument('--max-price-overhead', default=.1, type=float)
    ARGS.add_argument('--hours', default=5, type=float)
    ARGS.add_argument('--key-id')
    ARGS.add_argument('--key-secret')
    main(**vars(ARGS.parse_args()))
