import setuptools

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
