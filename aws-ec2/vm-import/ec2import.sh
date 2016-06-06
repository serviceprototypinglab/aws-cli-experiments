bucket=......

if [ ! -f ec2importpolicy.json ]
then
	sed -e "s/<disk-image-file-bucket>/$bucket/" ec2importpolicy.json.template > ec2importpolicy.json
	sed -e "s/<disk-image-file-bucket>/$bucket/" ec2import.json.template > ec2import.json
	aws iam create-role --role-name vmimport --assume-role-policy-document file://ec2importrole.json
	aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://ec2importpolicy.json
fi

aws ec2 import-image --description "somedescription" --disk-containers file://ec2import.json
