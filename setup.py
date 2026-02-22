import os
import shutil
import glob
import pathlib
from setuptools import setup


BASE_DIR = pathlib.Path(__file__).parent.resolve()

long_description = (BASE_DIR / "README.md").read_text(encoding="utf-8")


try:
    json_files = glob.glob(str(BASE_DIR / "src" / "*.json"))
    os.makedirs(BASE_DIR / "src" / "python" / "data", exist_ok=True)
    for json_file in json_files:
        os.symlink(
            json_file,
            BASE_DIR / "src" / "python" / "data" / os.path.basename(json_file),
        )
    setup(
        name="ifsc",
        version="0.0.1",
        author="sreevardhanreddi",
        author_email="sreevardhanreddi@gmail.com",
        description="This is part of the IFSC toolset released by Razorpay. You can find more details about the entire release at [ifsc.razorpay.com](https://ifsc.razorpay.com).",
        long_description=long_description,
        include_package_data=True,
        package_dir={"ifsc": "src/python"},
        package_data={"ifsc": ["data/*.json"]},
        python_requires=">=3.7",
        classifiers=[
            "Programming Language :: Python :: 3",
            "License :: OSI Approved :: MIT License",
            "Operating System :: OS Independent",
        ],
        project_urls={
            "Homepage": "https://github.com/razorpay/ifsc",
            "Source": "https://github.com/razorpay/ifsc",
        },
        install_requires=[
            "requests",
        ],
        test_suite="tests",
        zip_safe=False,
    )
except Exception as e:
    print("error: ", e, "during setup")
finally:
    shutil.rmtree(BASE_DIR / "src" / "python" / "data")
