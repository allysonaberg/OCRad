import numpy as np
 
import keras
 
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers.convolutional import Conv2D, MaxPooling2D
from keras.utils import np_utils
 
# (Making sure) Set backend as tensorflow
from keras import backend as K
K.set_image_dim_ordering('tf')

# Define some variables
num_rows = 28
num_cols = 28
num_channels = 1
num_classes = 10
 
# Import data
(X_train, y_train), (X_test, y_test) = mnist.load_data()
 
X_train = X_train.reshape(X_train.shape[0], num_rows, num_cols, num_channels).astype(np.float32) / 255
X_test = X_test.reshape(X_test.shape[0], num_rows, num_cols, num_channels).astype(np.float32) / 255
 
y_train = np_utils.to_categorical(y_train)
y_test = np_utils.to_categorical(y_test)

# Model
model = Sequential()
 
model.add(Conv2D(32, (5, 5), input_shape=(28, 28, 1), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.5))

model.add(Conv2D(64, (3, 3), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.2))
model.add(Conv2D(128, (1, 1), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.2))
model.add(Flatten())
model.add(Dense(128, activation='relu'))
model.add(Dense(num_classes, activation='softmax'))
 
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

# Training
model.fit(X_train, y_train, validation_data=(X_test, y_test), epochs=10, batch_size=200, verbose=2)

# Prepare model for inference
for k in model.layers:
    if type(k) is keras.layers.Dropout:
        model.layers.remove(k)

model.save('mnistCNN.h5')


import coremltools
 
output_labels = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
scale = 1/255.
coreml_model = coremltools.converters.keras.convert('./mnistCNN.h5',
                                                   input_names='image',
                                                   image_input_names='image',
                                                   output_names='output',
                                                   class_labels=output_labels,
                                                   image_scale=scale)
 
coreml_model.author = 'Sri Raghu Malireddi'
coreml_model.license = 'MIT'
coreml_model.short_description = 'Model to classify hand written digit'
 
coreml_model.input_description['image'] = 'Grayscale image of hand written digit'
coreml_model.output_description['output'] = 'Predicted digit'
 
coreml_model.save('mnistCNN.mlmodel')
