import os
import shutil
import glob
import pathlib
from setuptools import setup, find_packages


here = pathlib.Path(__file__).parent.resolve()

long_description = (here / "README.md").read_text(encoding="utf-8")


try:
    json_files = glob.glob(str(here / "src" / "*.json"))
    os.makedirs(str(here / "src" / "py_ifsc" / "data"), exist_ok=True)
    for json_file in json_files:
        os.symlink(
            json_file,
            str(here / "src" / "py_ifsc" / "data" / os.path.basename(json_file)),
        )
    setup(
        name="py_ifsc",
        version="0.0.1",
        include_package_data=True,
        package_data={"py_ifsc.data": ["*.json"]},
        zip_safe=False,
    )
except Exception as e:
    print(e)
finally:
    shutil.rmtree(str(here / "src" / "py_ifsc" / "data"))
