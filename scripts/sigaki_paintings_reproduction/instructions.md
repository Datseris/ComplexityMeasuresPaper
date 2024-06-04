# Reproduction of Sigaki et al. using ComplexityMeasures.jl

## Step 1: fetch metadata (using Python library)

We used the [wikiart crawler](https://github.com/lucasdavid/wikiart) by github user
`lucasdavid` to fetch metadata. The metadata, as downloaded per 4th of July 2023,
is the `data/meta` folder.

Each metadata file contains a JSON with information about
all the paintings for a given artist (e.g. `albert-bredow.json` contains the paintings
that Albert Bredow painted). We don't actually include these here, because the
entire catalogue of metadata takes up 240 mb of storage. Use the Python package
and follow its instructions to fetch the metadata.

### Download, analyse and plot data

The `sigaki_reanalysis.ipynb` notebook contains our reproduction and elaboration
on Sigaki et al.'s analysis.

- The notebook assumes that the `data/meta` folder has already been populated.
- Downloading and processing the data WILL NOT  work until you've used the Python
software to populate the metadata folder.
- Plotting the figure we included in our paper WILL work, because the results of our
    analysis (performed May 24th 2024) is in the `output` folder.
