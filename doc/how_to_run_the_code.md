# How to reproduce the results

## Requirements

- MATLAB 2017b
- Python
- Matplotlib, Basemap, jupyter notebook

## Data download

- Download [link][2] for pollutants concentration data for all main provincial cities.
- MODIS AOD data (under `data` directory)

## Usage

### Convert data into MATLAB mat file

- [`convert_MODIS_AOD_2_mat.m`](../src/convert_MODIS_AOD_2_mat.m) to convert the TXT file into mat file. **You may need to change the directories inside if you want to convert your own data**.
- [`convert_AQI_2_mat.m`](../src/convert_AQI_2_mat.m) to extract the data for your interested city and convert the data into mat file.

### Data analysis and visualization

- [`display_modis_aod.m`](../src/display_modis_aod.m): make the plot of MODIS AOD data.
- [`display_station_map.ipynb`](../src/display_station_map.ipynb): make the map of all ground stations.
- [`display_city_AQ.m`](../src/display_city_AQ.m): make the statistical plots of 6 pollutants.

## Q&A

### How to install **Basemap**?

- Download the pip wheel for basemap package download [link][1]
- `pip install *basemap*.whl`

[1]: https://www.lfd.uci.edu/~gohlke/pythonlibs/
[2]: http://beijingair.sinaapp.com/