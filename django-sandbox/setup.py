import os
import setuptools
import shutil
import sys

setuptools.setup(
    name="djangoauthtest",
    version="0.1.0",
    author="Ethan D. Twardy",
    author_email="ethan.twardy@gmail.com",
    description="Django Web Applications for edtwardy-webservices",
    url="https://github.com/AmateurECE/edtwardy-webservices",
    packages=['authtest'],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    install_requires=[
        'Django==3.2.4',
    ],
)

# Can't build two wheels in the same file, apparently...
if sys.argv[1] == 'bdist_wheel':
    shutil.rmtree('build/lib/authtest')
    uname=os.uname()
    os.mkdir(f'build/bdist.{uname[0].lower()}-{uname[4]}/wheel')

setuptools.setup(
    name="djangobasicsso",
    version="0.1.0",
    author="Ethan D. Twardy",
    author_email="ethan.twardy@gmail.com",
    description="Django Basic SSO making use of default Django auth system",
    url="https://github.com/AmateurECE/edtwardy-webservices",
    packages=['basicsso'],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    install_requires=[
        'Django==3.2.4',
    ],
)
