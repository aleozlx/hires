import os, sys
import logging, functools, itertools
from pathlib import Path
import numpy as np
import tensorflow as tf
import cv2
from global_vars import *

def test_hires(ctx):
    tf.keras.backend.clear_session()
    with tf.variable_scope('DataSouce'):
        def mapper(fname_im):
            im = tf.image.decode
        
        dataset = tf.data.Dataset.from_generator()

def main():
    pass

if __name__=='__main__':
    main()
