# MAGUSCP: Multiple sequence Alignment using Graph clUStering through Constraint Programming

Project for the Advanced Methods in Bioinformatics course at [VUB](www.vub.be).

Our contact information:

| Name              | Student number | Email address                                               |
| :---------------- | :------------- | :---------------------------------------------------------- |
| Wolf De Wulf      | 0546395        | [wolf.de.wulf@ed.ac.uk](mailto:wolf.de.wulf@ed.ac.uk)       |
| Dieter Vandesande | 0010000        | [dieter.vandesande@vub.be](mailto:dieter.vandesande@vub.be) |

## Usage

### 1. Installing requirements
Run the [`setup.sh`](scripts/local/setup.sh) script to create a virtual environment that has all the required python packages installed:

```console
./scripts/local/setup.sh
```

Then, activate that environment:

```console
source env/bin/activate
```

To deactivate the virtual environment, use:

```console
deactivate
```

### 2. Data

Run the [`download.sh`](data/download.sh) script to download the data:

```console
./data/download.sh
```

The aligned data is downloaded to `data/aligned`.

Run the [`unalign.py`](data/unalign.py) script using the required options to unalign the data:

```console
python data/unalign.py --help
```

The unaligned data is saved in `data/unaligned`.

### 3. Running

Run the [`magus.py`](MAGUS_CP/run.py) script to see what it can do:

```console
python MAGUS_CP/magus.py --help
```

## Reproducing the empirical evaluations

The scripts that were used to produce the results presented in the article can be found in the [`scripts/cluster`](scripts/cluster) folder.  

**Warning:** During research, all evaluations were ran on the [VUB AI lab HPC](https://comopc3.vub.ac.be/), running them locally can take a long time and a lot of memory.

If for some reason you want the results in `.csv` format or if you have questions, feel free to contact us via e-mail.