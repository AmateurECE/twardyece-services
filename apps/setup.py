import setuptools

setuptools.setup(
    name="edtwardy_apps",
    version="0.1.0",
    author="Ethan D. Twardy",
    author_email="ethan.twardy@gmail.com",
    description="Django Web Applications for edtwardy-webservices",
    url="https://github.com/AmateurECE/edtwardy-webservices",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.7',
    install_requires=[
        'Django==3.2.4',
    ],
    include_package_data=True,
)
