# https://arminreiter.com/2022/01/create-your-own-certificate-authority-ca-using-openssl/

# https://stackoverflow.com/a/62586085/11325184
# install openssl on windows (or use linux)
# choco install openssl

# list curves (prefer secp384r1, widely supported)
# openssl ecparam -list_curves

declare curve="secp384r1";
declare days="36500";

declare subj="/O=Vdb/C=RU/L=Moscow";
declare caName="vdb_root";
declare servers=(
    "vdb_ams"
    "vdb_stm"
    "vdb_vna"
);

# gen CA key
openssl ecparam -name ${curve} -genkey -noout -out $caName.key;

# gen CA cert
openssl req -x509 -new -noenc -days $days -key $caName.key -out $caName.crt -subj $subj;

mkdir "gen";
cd "gen";

for server in "${servers[@]}"
do
	# gen child keys
    openssl ecparam -name secp384r1 -genkey -noout -out $server.key;

	# gen child reqs
	openssl req -new -key $server.key -out $server.csr -subj $subj;

	# gen child certs
	# extfile is needed ONLY for use in browser
	openssl x509 -req -in $server.csr -CA ../$caName.crt -CAkey ../$caName.key -CAcreateserial -out $server.crt -days $days # -extfile $server.v3.ext
done