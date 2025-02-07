GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
        exit 1
    fi
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

gitlab_password=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode)
echo "GitLab password: $gitlab_password"

# # Create Personal Access Token
echo "Creating GitLab token..."
TOKEN_RESPONSE=$(curl -s --request POST "http://gitlab.localhost:8080/api/v4/personal_access_tokens" \
  --header "Content-Type: application/json" \
  --user "root:${gitlab_password}" \
  --data '{
    "name": "gitlab-token",
    "scopes": ["api", "read_user", "read_repository", "write_repository"]
  }')

export GITLAB_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.token')

# Create project structure
# mkdir -p /tmp/p3/{src/public,confs}
# cd /tmp/p3

# Create Kubernetes manifests
sudo cat > confs/deployment.yaml <<EOF
# Deployment
apiVersion: apps/v1             # Kubernetes API version for Deployment resource
kind: Deployment                # Type of Kubernetes resource
metadata:
  name: wil-playground          # Name and namespace of the Deployment
  namespace: dev
spec:                           # Specification of the Deployment
  selector:
    matchLabels:
      app: wil-playground       # Label to match Pods managed by this Deployment
  template:
    metadata:
      labels:
        app: wil-playground     # Labels applied to Pods created from this template
    spec:
      containers:
      - name: wil               # Name of the container
        image: wil42/playground:v1  # Docker image to use for the container
        ports:
        - containerPort: 8888   # Port exposed by the container

---

# Service
apiVersion: v1                  # Kubernetes API version for Service resource
kind: Service                   # Tyfe of Kubernetes resource
metadata:
  name: svc-wil-playground      # Name of the Service
  namespace: dev
spec:
  selector:
    app: wil-playground         # Labels used to identify Pods that the Service will route traffic to
  ports:
    - protocol: TCP             # Protocol used for the port
      port: 8080                # Port number on the Service that clients can connect to
      targetPort: 8888          # Port number on the Pods to which the Service will forward traffic


# The Service acts as an abstraction layer that provides a stable endpoint for accessing the Pods 
#  that are part of the Deployment. Instead of directly accessing individual Pods (which can be dynamic 
#  and change over time), clients interact with the Service, which internally routes requests to the
#  appropriate Pods. The port configuration ensures that traffic is correctly routed from external 
#  clients to the Pods where the application is running.
EOF


# Create GitLab project
echo "Creating GitLab project..."
curl -X POST "http://gitlab.localhost:8080/api/v4/projects" \
  --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
  --data "name=aomman-bonus-website"
check_status "GitLab project created"

# Setup git and push
git init
git config --global user.email "admin@example.com"
git config --global user.name "Administrator"
git add .
git commit -m "Initial deployment"
git remote add origin "http://root:${gitlab_password}@gitlab.localhost:8080/root/aomman-bonus-website.git"
git push -u origin master
check_status "Code pushed to GitLab"

# Create ArgoCD configuration
sudo cat > confs/argocd.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: aomman-bonus-website
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/aomman-bonus-website.git'
    targetRevision: HEAD
    path: confs
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: aomman-bonus-website
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/aomman-bonus-website.git'
    targetRevision: HEAD
    path: confs
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
kubectl apply -f confs/argocd.yaml

kubectl port-forward svc/svc-wil-playground -n dev 9092:8080
check_status "ArgoCD configured"


echo -e "${GREEN}Setup completed successfully!${NC}"
echo "To test changes:"
echo "1. Edit src/public/index.html"
echo "2. Commit and push changes"
echo "3. ArgoCD will automatically deploy the new version"

echo "to access to argocd use the following command"
echo "kubectl port-forward svc/argocd-server -n argocd 8888:443"
echo "to get password use the following command"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
