#MODULES
import time
import matplotlib.pyplot as pyplot
import numpy as numpy
from keras.models import Sequential
from keras.layer import Dense
from keras.layers import Dropout
from keras.layers import Flatten
from keras.constraints import maxnorm
from keras.optimizers import SGD
from keras.layers import Activation
from keras.layers.convolutional import Convo2D
from keras.layers.convolutional import MaxPooling2D
from keras.layers.normalization import BatchNormalization
from keras.utils import np_utils
from keras_sequential_Ascii import sequential_model_to_ascii_printout
from keras import backend as K 
if K.backend() =='tensorflow':
	K.set_image_dim_ordering("th")

#IMPORT TENSORFLOW
import tensorflow as tensorflow
import multiprocessing as mp 

#LOADING DATASET
from keras.datasets import cifar10

#DECLARING VARIABLES
batch_size = 32 #number of training examples in one pass
num_classes = 10 #number of cifar10 data set classes (horse, cat, dog, etc...)
epochs = 100 # 1 epoch = 1 cycle of forward + backward propogation of all training examples


#loading CIFAR-10 and PROCESSING
(x_train, y_train), (x_test, y_test) = cifar10.load_data()

#create a 5*2 plot of images, with examples from EACH CLASS
fig = plt.figure(figsize=(8,3))
for i in range(num_classes):
	ax = fig.add_subplot(2, 5, 1 + i, xticks=[], yticks=[])
	idx = np.where(y_train[:] ==i)[0]
	features_idx = x_train[idx,::]
	img_num = np.random.randint(features_idk.shape[0])
	im = np.transpose(features_idk[img_num,::],(1,2,0))
	ax.set_title(class_names[i])
	plt.imshow(im)

plot.show()

#now, we want to normalize to 0->255 pixel data to 0->1
#pre-processing
#produces vectors of integers from 0->1 for each class
y_train = np_utils.to_categorical(y_train, num_classes)
y_test = np_utils.to_categorical(y_test, num_classes)
x_train = x_train.astype('float32')
x_test = x_test.astype('float32')
x_train /=255
x_test /=255






