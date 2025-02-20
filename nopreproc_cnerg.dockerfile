FROM ghcr.io/pyne/pyne_ubuntu_22.04_py3_hdf5/pyne-dev 

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6 nano expect -y

ENV HOME=/root
ENV HDF5_ROOT=/root/opt/hdf5/hdf5-1_12_0/

RUN mkdir -p $HOME/root/openmc/build && \
    cd $HOME/root/openmc && \
    git clone --recurse-submodules https://github.com/openmc-dev/openmc.git && \
    cd openmc && \
    git checkout 5bc04b5d78b83684685ccf53564498493e2b6a93 && \
    cd ../ && \
    cd build && \
    cmake ../openmc \
    -DCMAKE_INSTALL_PREFIX=$HOME/opt/openmc \
    -DOPENMC_USE_LIBMESH=on \    
    -DCMAKE_PREFIX_PATH=$HOME/libmesh/libmesh_bld \
    -DOPENMC_USE_DAGMC=ON \
    -DDAGMC_ROOT=$HOME/opt/dagmc \
    -DCMAKE_BUILD_TYPE=Release .. && \
    make install -j18

RUN	cd $HOME/root/openmc/openmc && \
    python -m pip install .

ENV PATH=/root/opt/openmc/bin:$PATH

RUN pip install --no-cache-dir progress
RUN pip install --no-cache-dir vtk
RUN pip install --no-cache-dir openmc-plasma-source
RUN pip install --no-cache-dir PyYAML

WORKDIR "/root"
ENV PYTHONPATH=/root/.local/lib/python3.10/site-packages:$PYTHONPATH

WORKDIR /opt

RUN wget -O fendl.xz https://anl.box.com/shared/static/3cb7jetw7tmxaw6nvn77x6c578jnm2ey.xz
RUN tar -xf fendl.xz
RUN rm -f fendl.xz
ENV OPENMC_CROSS_SECTIONS=/opt/groupspace/cnerg/common/data/openmc/endfb-viii.0-hdf5/cross_sections.xml
ENV PATH=$HOME/opt/dagmc/bin:$HOME/opt/dagmc/lib:$HOME/opt/dagmc/moab/bin:$HOME/opt/moab/bin:$PATH