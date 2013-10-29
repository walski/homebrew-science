require 'formula'

class Opencv < Formula
  homepage 'http://opencv.org/'
  url 'http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.6.1/opencv-2.4.6.1.tar.gz'
  sha1 'e015bd67218844b38daf3cea8aab505b592a66c0'

  option '32-bit'
  option 'with-qt',  'Build the Qt4 backend to HighGUI'
  option 'with-tbb', 'Enable parallel code in OpenCV using Intel TBB'
  option 'without-opencl', 'Disable gpu code in OpenCV using OpenCL'

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'numpy' => :python
  depends_on :python

  depends_on 'eigen'   => :optional
  depends_on 'libtiff' => :optional
  depends_on 'jasper'  => :optional
  depends_on 'tbb'     => :optional
  depends_on 'qt'      => :optional
  depends_on :libpng

  # Can also depend on ffmpeg, but this pulls in a lot of extra stuff that
  # you don't need unless you're doing video analysis, and some of it isn't
  # in Homebrew anyway. Will depend on openexr if it's installed.
  depends_on 'ffmpeg' => :optional

  def install
    args = std_cmake_args + %W[
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DWITH_CUDA=OFF
      -DBUILD_ZLIB=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_PNG=OFF
      -DBUILD_JPEG=OFF
      -DBUILD_JASPER=OFF
      -DBUILD_TESTS=OFF
      -DBUILD_PERF_TESTS=OFF
      -DPYTHON_INCLUDE_DIR='#{python.incdir}'
      -DPYTHON_LIBRARY='#{python.libdir}/lib#{python.xy}.dylib'
      -DPYTHON_EXECUTABLE='#{python.binary}'
    ]

    if build.build_32_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
      args << "-DOPENCV_EXTRA_C_FLAGS='-arch i386 -m32'"
      args << "-DOPENCV_EXTRA_CXX_FLAGS='-arch i386 -m32'"
    end
    args << '-DWITH_QT=ON' if build.with? 'qt'
    args << '-DWITH_TBB=ON' if build.with? 'tbb'
    # OpenCL 1.1 is required, but Snow Leopard and older come with 1.0
    args << '-DWITH_OPENCL=OFF' if build.without? 'opencl' or MacOS.version < :lion
    args << '-DWITH_FFMPEG=OFF' unless build.with? 'ffmpeg'

    args << '..'
    mkdir 'macbuild' do
      system 'cmake', *args
      system "make"
      system "make install"
    end
  end

  def patches
    DATA
  end

  def caveats
    python.standard_caveats if python
  end
end

__END__
diff --git a/modules/legacy/src/dpstereo.cpp b/modules/legacy/src/dpstereo.cpp
index a55e1ca..dd7e642 100644
--- a/modules/legacy/src/dpstereo.cpp
+++ b/modules/legacy/src/dpstereo.cpp
@@ -76,7 +76,7 @@ typedef struct _CvRightImData
     uchar min_val, max_val;
 } _CvRightImData;
 
-#define CV_IMAX3(a,b,c) ((temp3 = (a) >= (b) ? (a) : (b)),(temp3 >= (c) ? temp3 : (c)))
+#define CV_IMAX3(a,b,c) ((temp2 = (a) >= (b) ? (a) : (b)),(temp2 >= (c) ? temp2 : (c)))
 #define CV_IMIN3(a,b,c) ((temp3 = (a) <= (b) ? (a) : (b)),(temp3 <= (c) ? temp3 : (c)))
 
 static void icvFindStereoCorrespondenceByBirchfieldDP( uchar* src1, uchar* src2,
@@ -87,7 +87,7 @@ static void icvFindStereoCorrespondenceByBirchfieldDP( uchar* src1, uchar* src2,
                                                 float  _param3, float _param4,
                                                 float  _param5 )
 {
-    int     x, y, i, j, temp3;
+    int     x, y, i, j, temp2, temp3;
     int     d, s;
     int     dispH =  maxDisparity + 3;
     uchar  *dispdata;

