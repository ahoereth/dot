"""Jupyter notebook python configuration."""


def pre_save_scrub_output(model, path, contents_manager):
    """Scrub output before saving notebooks.

    As seen on:
    github.com/jupyter/notebook/blob/d751f1/docs/source/extending/savehooks.rst
    """
    if model['type'] != 'notebook':  # Only run on notebooks.
        return
    if model['content']['nbformat'] != 4:  # Only run on nbformat v4.
        return
    for cell in model['content']['cells']:  # Clear each cell.
        if cell['cell_type'] != 'code':
            continue
        cell['outputs'] = []
        cell['execution_count'] = None
        if 'metadata' in cell:
            if 'collapsed' in cell['metadata']:
                del cell['metadata']['collapsed']
            if 'scrolled' in cell['metadata']:
                del cell['metadata']['scrolled']


def pre_save(model, path, contents_manager):
    """Run functions before saving a file."""
    funcs = [pre_save_scrub_output]
    for func in funcs:
        func(model=model, path=path, contents_manager=contents_manager)


def post_save(model, os_path, contents_manager):
    """Run functions after saving a file."""
    funcs = []
    for func in funcs:
        func(model=model, os_path=os_path, contents_manager=contents_manager)


# pylint:disable=E0602
c.FileContentsManager.pre_save_hook = pre_save  # type: ignore
c.FileContentsManager.post_save_hook = post_save  # type: ignore
