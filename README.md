GEOTRACK
========

This app logs locality name, geolocation, current date/time, and battery level once every hour. The app logs from the background and wakes from reset of the device. App shows last 50 geotags in a table.

Version History
===============

- v0.1 Added UITableView and UINavigationController and hookups
- v0.4 Added background processing, geotagging, and parse backend
- v0.7 Added fixes, icons, and this README

Issues
======

- On wake up from device restart, geotag is logged three times instead of once.
- Error handling for updating parse backend is needed. If save to parse is unsuccessful, geotag should be saved to file to be saved at a later time.
- It may be possible to not use startMonitoringSignificantLocationChange and still get wake up functionality. This would save a great deal of battery.
- Battery level is in increments of 5%. Could use interpolation for higher resolution.
- If burst rate  is an issue on parse for heavy user load, may want to consolidate save calls by saving to local file first.
