'''

Properties of the measurement stations

'''
import numpy as np
import os

lons=[360.0-11.25, 11.25, 56.25, 360.0-63.75, 78.75,
                   360.0-88.75, 360.0-96.25, 111.25, 121.25, 128.75,
                   158.75, 161.25, 171.25, 9.904, 360.0-122.91,
                   360.0-20.30, 360.0-80.25, 360.0-59.43, 360.0-60,
                   18.48, 306.0-64.05, 144.68, 62.50, 360.0-67.4, 360.0-64.7,
                   360.-130., 360.0-62.5, 360.0-62.953, 25.67, 360.0-27.35]
                #    filter_samples$Longitude)
lats=[41., -19., -21., 33., -37., 27., 25.,
                   -41., 7., 33., 37., 21., -23., 53.326, 38.12,
                   63.40, 25.75, 13.17, -51.75,
                  -34.35, -64.77, -40.68, -67.60, 41.9, 36.3,
                  10., 82.46, 37.88261, 35.33, 38.]
names=["west of Portugal", "west of Namibia", "La Reunion Island",
                   "Bermuda", "Amsterdam Island", "Gulf of Mexico (north)",
                   "Gulf of Mexico (west)", "southwest of Australia",
                   "Philippines", "south of South Korea", "North Pacific Ocean 1",
                   "North Pacific Ocean 2", "New Caledonia", "Mace Head", "Point Reyes",
                   "Heimaey, Iceland", "Miami, Florida", "Ragged Point; Barbados",
                   "Falkland Islands", "Cape Point, South Africa", "Palmer Station, Antarctica",
                   "Cape Grim, Tasmania", "Mawson - Antarctica",
                   "WACS-I - George's Bank", "WACS-I - Sargasso Sea",
                   "SPURS-2", "Alert", "WACS-II", "Finokalia", "Azores"]
