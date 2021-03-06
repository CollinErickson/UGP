
import numpy as np
import csv
import timeit
import GPy
import sys


#put in data
# X = 
# y = 
# xp = 
# ypa = 
# inputdim = 


X = [[ 0.27027    ,0.65781  ],
 [ 0.8715     ,0.1115   ],
 [ 0.49945    ,0.060403 ],
 [ 0.84728    ,0.28272  ],
 [ 0.95277    ,0.49616  ],
 [ 0.17031    ,0.48416  ],
 [ 0.56226    ,0.4001   ],
 [ 0.94735    ,0.55469  ],
 [ 0.99028    ,0.96181  ],
 [ 0.77028    ,0.30652  ],
 [ 0.80712    ,0.58381  ],
 [ 0.30631    ,0.87225  ],
 [ 0.20732    ,0.73617  ],
 [ 0.72281    ,0.018641 ],
 [ 0.97132    ,0.030253 ],
 [ 0.17318    ,0.42378  ],
 [ 0.78039    ,0.99053  ],
 [ 0.31258    ,0.17008  ],
 [ 0.52347    ,0.93012  ],
 [ 0.14135    ,0.077475 ],
 [ 0.41445    ,0.36769  ],
 [ 0.69882    ,0.16465  ],
 [ 0.7245     ,0.097417 ],
 [ 0.48797    ,0.24477  ],
 [ 0.82186    ,0.82748  ],
 [ 0.76894    ,0.96442  ],
 [ 0.35652    ,0.71918  ],
 [ 0.21261    ,0.011933 ],
 [ 0.1664     ,0.51646  ],
 [ 0.023479   ,0.75236  ],
 [ 0.63801    ,0.19346  ],
 [ 0.40975    ,0.99858  ],
 [ 0.054447   ,0.96237  ],
 [ 0.14285    ,0.37471  ],
 [ 0.20021    ,0.3485   ],
 [ 0.68981    ,0.69512  ],
 [ 0.0035586  ,0.77444  ],
 [ 0.50505    ,0.16148  ],
 [ 0.45487    ,0.14953  ],
 [ 0.45352    ,0.077334 ]]

y = [-0.24663  , 0.42053  , 0.98468  , 1.3746  , -1.0237  , -1.2957  ,  0.41022,
  0.011283 ,-1.0611   , 1.4767   , 1.8508   , 1.0569   ,-1.2191   ,-0.17983,
  0.029257 ,-1.8771   , 0.4558   , 0.094312 ,-0.42661  , 0.53055  ,-0.65425,
 -1.7993   , 0.041109 ,-0.42886  , 1.9024   ,-0.32149  ,-0.25136  ,-0.51194,
 -0.46071  , 0.61578  ,-1.31     ,-0.80223  , 0.16861  ,-0.42654  ,-0.3316  , -1.98,
  0.6656   ,-0.66712  ,-1.4844   , 0.01126 ]


X = np.asmatrix(X)
y = np.asmatrix(y).reshape((40,1))


inputdim = 2


kernel = GPy.kern.RBF(input_dim=inputdim, variance=1., lengthscale=[1. for iii in range(inputdim)],ARD=True)

#np.random.seed(int(filesToRun[i,7]))

gp = GPy.models.GPRegression(X,y,kernel,normalizer=True) # added normalizer to make better

gp.likelihood.variance = 1e-8 # added 1/12/16, Max Zweissele says it will help with GPy issues.

gp.optimize(messages=False)
#print gp.param_array
gp.optimize_restarts(num_restarts = 5,  verbose=False)
#print gp.param_array
#y_pred, sigma2_pred = gp.predict(xp, eval_MSE=True)
y_pred, sigma2_pred = gp.predict(np.asarray(xp))
