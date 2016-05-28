#
# Instructions based on https://github.com/awslabs/certlint/tree/master/build-x509helper
#
export X509_HELPER="/usr/local/certlint/build-x509helper"

cd $X509_HELPER/asn1c
patch -t -p1 < $X509_HELPER/asn1c.patch
autoreconf -iv
./configure
make

cp $X509_HELPER/pkix-smimecaps.asn1 $X509_HELPER/asn1c/examples
cp $X509_HELPER/MiscAttr.asn1 $X509_HELPER/asn1c/examples

cd $X509_HELPER/asn1c/examples
curl -O https://www.ietf.org/rfc/rfc3739.txt
./crfc2asn1.pl rfc3739.txt
curl -O https://www.ietf.org/rfc/rfc3709.txt
./crfc2asn1.pl rfc3709.txt
curl -O https://www.ietf.org/rfc/rfc3279.txt
./crfc2asn1.pl rfc3279.txt

mkdir $X509_HELPER/asn1c/examples/pkix1
cd $X509_HELPER/asn1c/examples/pkix1
bash $X509_HELPER/regen-pkix1-Makefile
make

# Symlink the helper so that it's in the user's $PATH
ln -s $X509_HELPER/asn1c/examples/pkix1/certlint-x509helper /usr/local/bin/
