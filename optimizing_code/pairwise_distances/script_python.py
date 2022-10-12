
import numpy as np
import scipy
import time

n_features = 128
n_examples = 1000_000
n_clusters = 256

X = np.random.rand(n_examples, n_features).astype(np.float32)
Y = np.random.rand(n_clusters, n_features).astype(np.float32)

t0 = time.time()
aux = scipy.cluster.vq.vq(X, Y, check_finite=False)
print('time taken', time.time()-t0)