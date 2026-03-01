
## Derivation of Lattice Boltzmann with BGK

Defined by DxQy where x is numebr of dimensions and y is number of vectors

Starting from the Boltzmann Equation

$\frac{d F}{dt} \equiv \frac{\partial f}{\partial t} + \vec{\xi} \cdot \nabla_{\vec{x}} f + \frac{\vec{F}}{m} \cdot \nabla_{\vec{\xi}} f = \left( \frac{\partial f}{\partial t} \right)_{coll}$,

where $f(\vec{x}, \vec{\xi}, t)$ is the particle probability distribution function,  $\vec{x}$ is position, $\vec{\xi}$ is velocity and t is time. 

To discretize this equation we do the following

At each lattice point $\vec{x}$ we have a distribution $f_i$ for each velocity direction $\vec{e_i}$

$f(\vec{x}, \vec{\xi}, t) \Rightarrow f_i(\vec{x}, t) \equiv w_i f(\vec{x}, \vec{e}_i, t)$

Where $\vec{e_i}$ is a velocity vector and $w_i$ is it's weight factor

Example D2Q9: 

![[images/D2Q9_lattice_vectors_for_2D_Lattice_Boltzmann.svg.png]]

$\vec{e}_i = \begin{cases} (0,0) & i=0 \\ (\pm 1, 0), (0, \pm 1) & i=1,2,3,4 \\ (\pm 1, \pm 1) & i=5,6,7,8 \end{cases}.$

Each velocity describes a direction where $0$ is the center so particles which have no velocity, $[1,2,3,4]$ is the cardinal directions and $[5,6,7,8]$ the diagonal directions. Each direction has a weight $w_i$ in the distribution. 

We assume in one time step a packed moves exactly to the next node

$\Delta \vec{x} = \vec{e}_i \Delta t$


BGK (Bhatnagar-Gross_krook) collision approximation where external force $\vec{F}=0$

$\left( \frac{\partial f}{\partial t} \right)_{coll} \approx -\frac{1}{\tau} (f - f^{eq})$ 

Where $f^{eq}$ is the equilibrium density usually computed via a Taylor expansion. The term $\tau$ describes a unitless characteristic timescale for which the fluid relaxes locally. This timescale determines the kinematic viscosity. 

Now we can write per velocity direction

$\frac{\partial f_i}{\partial t} + \vec{e}_i \cdot \nabla_{\vec{x}} f_i = -\frac{1}{\tau} (f_i - f_i^{eq})$

Now integrate both sides by a small time step $dt'$ since 

$\frac{\partial f_i}{\partial t} + \vec{e}_i \cdot \nabla_{\vec{x}} f_i \equiv  \frac{df_i}{dt}$

$\int_{0}^{\Delta t} \frac{Df_i}{Dt} dt' = \int_{0}^{\Delta t} -\frac{1}{\tau} (f_i - f_i^{eq}) dt'$

Fundamental theorem of calculus and using the assumption $\Delta \vec{x} = \vec{e}_i \Delta t$:

$f_i(\vec{x} + \vec{e}_i \Delta t, t + \Delta t) - f_i(\vec{x}, t) = \text{Collision Integral}$

Assuming that the collision term is constant over $\Delta t$ 

$f_i(\vec{x} + \vec{e}_i \Delta t, t + \Delta t) - f_i(\vec{x}, t) \approx -\frac{\Delta t}{\tau} (f_i(\vec{x}, t) - f_i^{eq}(\vec{x}, t))$ 

For our simulation units we set $\Delta t = 1$

$f_i(\vec{x} + \vec{e}_i, t + 1) - f_i(\vec{x}, t) \approx -\frac{1}{\tau} (f_i(\vec{x}, t) - f_i^{eq}(\vec{x}, t))$ 

And we get our algorithm

Step 1. Compute the distribution for the neighbour

$f_i^{update}(\vec{x}, t) = f_i(\vec{x}, t) - \frac{1}{\tau} (f_i(\vec{x}, t) - f_i^{eq}(\vec{x}, t))$

Step 2 Update the neigbour

$f_i(\vec{x} + \vec{e}_i, t + 1) = f_i^{update}(\vec{x}, t)$

Variation in collision term approximation but by default HemeLB uses BGK

## Consequence

- Lattice boltzmann is a very local algorithm only caring about local interaction. 
- Additionally it lends itself to complex geometries due to the discretization process. 
- Thus it lends itself naturally to parallel compute

Picture of D3Q19
https://www.researchgate.net/figure/D3Q19-model-for-the-LBM-approach_fig1_341983446
