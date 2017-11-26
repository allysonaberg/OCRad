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


#OVERVIEW OF The CNN MODEL:
#-four layers, convolutional
def base_model():

    model = Sequential()
    model.add(Conv2D(32, (3, 3), padding='same', input_shape=x_train.shape[1:]))
    model.add(Activation('relu'))
    model.add(Conv2D(32,(3, 3)))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))

    model.add(Conv2D(64, (3, 3), padding='same'))
    model.add(Activation('relu'))
    model.add(Conv2D(64, (3,3)))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))

    model.add(Flatten())
    model.add(Dense(512))
    model.add(Activation('relu'))
    model.add(Dropout(0.5))
    model.add(Dense(num_classes))
    model.add(Activation('softmax'))

    sgd = SGD(lr = 0.1, decay=1e-6, momentum=0.9 nesterov=True)

# Train model

    model.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])
    return model
cnn_n = base_model()
cnn_n.summary()

# Fit model

cnn = cnn_n.fit(x_train, y_train, batch_size=batch_size, epochs=epochs, validation_data=(x_test,y_test),shuffle=True)


# Vizualizing model structure
sequential_model_to_ascii_printout(cnn_n)

# Plots for training and testing process: loss and accuracy

plt.figure(0)
plt.plot(cnn.history['acc'],'r')
plt.plot(cnn.history['val_acc'],'g')
plt.xticks(np.arange(0, 101, 2.0))
plt.rcParams['figure.figsize'] = (8, 6)
plt.xlabel("Num of Epochs")
plt.ylabel("Accuracy")
plt.title("Training Accuracy vs Validation Accuracy")
plt.legend(['train','validation'])


plt.figure(1)
plt.plot(cnn.history['loss'],'r')
plt.plot(cnn.history['val_loss'],'g')
plt.xticks(np.arange(0, 101, 2.0))
plt.rcParams['figure.figsize'] = (8, 6)
plt.xlabel("Num of Epochs")
plt.ylabel("Loss")
plt.title("Training Loss vs Validation Loss")
plt.legend(['train','validation'])


plt.show()


scores = cnn_n.evaluate(x_test, y_test, verbose=0)
print("Accuracy: %.2f%%" % (scores[1]*100))

# Confusion matrix result

from sklearn.metrics import classification_report, confusion_matrix
Y_pred = cnn_n.predict(x_test, verbose=2)
y_pred = np.argmax(Y_pred, axis=1)

for ix in range(10):
    print(ix, confusion_matrix(np.argmax(y_test,axis=1),y_pred)[ix].sum())
cm = confusion_matrix(np.argmax(y_test,axis=1),y_pred)
print(cm)

# Visualizing of confusion matrix
import seaborn as sn
import pandas  as pd


df_cm = pd.DataFrame(cm, range(10),
                  range(10))
plt.figure(figsize = (10,7))
sn.set(font_scale=1.4)#for label size
sn.heatmap(df_cm, annot=True,annot_kws={"size": 12})# font size
plt.show()


