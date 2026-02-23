# SCC Training 04 - ASCOT5

Date 23.2. at 13:00 - 17:00  
At Aalto - Otaniemi, Otakaari 1, U121b (Undergraduate Centre, 1st floor)  

Find the materials here:

- [Profiling slides](https://kannu.csc.fi/s/M72gxKSxMY7mHKm)
- ASCOT5 slides (ascot5-slides.pdf)
- [ASCOT5 docs](https://ascot4fusion.github.io/ascot5/index.html)
- ~[ASCOT5 python fix](https://github.com/ascot4fusion/ascot5/issues/195)~
  - Edit `pyproject.toml`: `  "numpy",` --> `  "numpy==2.1",`
  - Run `pip install -e .`
- extra: [ASCOT5 GPU port technical details](https://indico.euro-fusion.org/event/2845/attachments/5037/8946/Foourestey_ASCOT5.pdf)
- extra: [ASCOT5 info slides](https://hpcfusion.bsc.es/2023/wp-content/uploads/sites/7/2023/12/Snicker-kurki.pdf)
- extra: [ASCOT5 GPU port info](https://hpcfusion.bsc.es/2024/wp-content/uploads/sites/8/2024/11/Mathieu-Peybernes_FusionHPC-Workshop-1.pdf)
- extra: [HDF5 learning resources](https://support.hdfgroup.org/documentation/hdf5/latest/_getting_started.html)


## Agenda

|Time|Topic|
|---|---|
|13:00|DFTB+ discussion|
|13:15|Profiling|
|13:30|Libmpritrace demo with DFTB+|
|13:45|Overview of ASCOT5, HDF5|
|14:00|Coffee break|
|14:15 - 17:00|Using GPU accelerated ASCOT5 on Mahti|
|14:15 - 17:00|Optimization options|
|14:15 - 17:00|Hands-on|

## Hands-on exercises

- [DFTB+ profiling demo](exercises/profiling_dftb_demo.md)
- [ASCOT5 tutorials](https://ascot4fusion.github.io/ascot5/tutorials.html)
