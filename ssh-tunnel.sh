
# read service credentials and address 

APP_NAME=content-package-store
SERVICE_NAME=postgresql
cf curl /v3/apps/$(cf app $APP_NAME --guid)/env | jq -r ".system_env_json"
SERVICE_HOST=$(cf curl /v3/apps/$(cf app $APP_NAME --guid)/env | jq -r ".system_env_json.VCAP_SERVICES.$SERVICE_NAME | .[0].credentials | .hostname")
SERVICE_PORT=$(cf curl /v3/apps/$(cf app $APP_NAME --guid)/env | jq -r ".system_env_json.VCAP_SERVICES.$SERVICE_NAME | .[0].credentials | .port")
echo $SERVICE_HOST
echo $SERVICE_PORT

# setup ssh tunnel

SSH_CODE=$(cf ssh-code)
echo $SSH_CODE
app_ssh_endpoint=$(cf curl /v2/info | jq -r ".app_ssh_endpoint" )
echo $app_ssh_endpoint 
SSH_ENDPOINT=$(echo $app_ssh_endpoint | awk '{split($0,a,":"); print a[1] }')
SSH_PORT=$(echo $app_ssh_endpoint | awk '{split($0,a,":"); print a[2] }')
echo $SSH_ENDPOINT
echo $SSH_PORT
/usr/local/bin/sshpass -p $SSH_CODE ssh -p $SSH_PORT -L 5000:$SERVICE_HOST:$SERVICE_PORT cf:$(cf curl /v3/apps/$(cf app $APP_NAME --guid)/processes | jq -r '.resources[] | select(.type=="web") | .guid')/0@$SSH_ENDPOINT
