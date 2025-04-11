from setuptools import setup, find_packages

setup(
    name="dataflow-doc-generator",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "pyvis>=0.3.2",
        "networkx>=3.1",
        "PyYAML>=6.0.1",
        "loguru>=0.7.2",
        "neo4j-driver>=5.18.0",
        "cryptography>=42.0.0",
    ],
    python_requires=">=3.10",
) 