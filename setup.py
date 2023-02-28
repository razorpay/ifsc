import os
import shutil
import glob
import pathlib
from setuptools import setup, find_packages


BASE_DIR = pathlib.Path(__file__).parent.resolve()

long_description = (BASE_DIR / "README.md").read_text(encoding="utf-8")


try:
    json_files = glob.glob(str(BASE_DIR / "src" / "*.json"))
    os.makedirs(str(BASE_DIR / "src" / "python" / "data"), exist_ok=True)
    for json_file in json_files:
        os.symlink(
            json_file,
            str(BASE_DIR / "src" / "python" / "data" / os.path.basename(json_file)),
        )
    setup(
        name="ifsc",
        version="0.0.1",
        include_package_data=True,
        package_dir={"ifsc": "src/python"},
        package_data={"ifsc.data": ["*.json"]},
        zip_safe=False,
    )
except Exception as e:
    print(e)
finally:
    shutil.rmtree(str(BASE_DIR / "src" / "python" / "data"))
