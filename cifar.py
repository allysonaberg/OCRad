from keras.datasets import cifar10 #the dataset
from matplotlib import pyplot #matlab-like plotting framework
from scipy.misc import toimage #numpy -> image

#loading dataset
(X_train, y_train), (X_test, y_test) = cifar10.load_data() #stored into ~/.keras/datasetst

