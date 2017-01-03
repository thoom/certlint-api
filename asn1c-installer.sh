#
# Instructions based on https://github.com/awslabs/certlint/blob/master/ext/README
#
cd /usr/local/certlint/ext/asn1c

autoreconf -iv
./configure
make
cd ..

asn1c/asn1c/asn1c -S asn1c/skeletons -pdu=all -pdu=Certificate -fwide-types *.asn1
rm converter-sample.c

# RFC3280 has a Time type which will cause the compiler to create a Time.h
# file. This will conflict with <time.h> on a case insensitive filesystem.
# You can work around this problem with this hack:
#
mv Time.h TTime.h
perl -pi -e 's/"Time.h"/"TTime.h"/g' *

ruby extconf.rb
make

#symlink so that the asn1validator is available on the class path
ln -s /usr/local/certlint/ext/asn1validator.so /usr/local/certlint/lib