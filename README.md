# Azure FunBytes - Getting Started with WASM and Azure

[Based on my Getting Started with Hippo blog post series.](https://dev.to/smurawski/series/15635)

## What is WebAssembly or WASM?

WebAssembly is a compact, low-level language with a binary format, initially designed to run in the browser.


## Our First WASM Project

```
pushd src/funbytes
cargo build --target wasm32-wasi
```

## What is WASI?

WASI or WebAssembly System Interface, which is a standard for how the WebAssembly engine can be exposed to the underlying system resources. It offers a controlled path to system resources and requires explicit delegation of resources to the WebAssembly engine. It covers capabilities like file system access, networking, and other core operating system features (like random number generation).

Wasmtime is an implementation of a WASM runtime (hence wasmtime) that implements the WASI standard. 

## Running a WebAssembly Project in Wasmtime

```
wasmtime ./target/wasm32-wasi/debug/funbytes.wasm
popd
```

## What is WAGI?

WebAssembly Gateway Interface or WAGI allows you to run WebAssembly WASI binaries as HTTP handlers. WAGI is the foundation for Hippo and Krustlet, which we'll take a deeper look at.

## What is [Hippo](https://github.com/deislabs/hippo)?

Hippo is a Platform-as-a-Service (PaaS) designed to provide a hosting environment that makes following cloud-native best practices easier. Hippo uses WAGI to provide a sandboxed, secure, and highly performant runtime environment with a great developer experience.

## Getting Started with [Hippo in Azure](https://github.com/smurawski/hippo-dev)

### Create a Dev/Test Environment

```powershell
pushd src/provisioning
./New-HippoDevEnvironment -ResourceGroupName funbytes_wasm_live -VMName funbyteslive
ssh ubuntu@funbyteslive.westus2.cloudapp.azure.com
cat ~/output.txt
exit
popd
```

### Create Our App

```
mkdir src/funbytes
pushd src/funbytes_live

$env:USER = 'admin'
$env:HIPPO_USERNAME ='admin'
$env:HIPPO_PASSWORD = 'Passw0rd!'
$env:HIPPO_URL = 'https://hippo.minimallyviable.io:5001'
$env:BINDLE_URL = 'http://hippo.minimallyviable.io:8080/v1'
$env:GLOBAL_AGENT_FORCE_GLOBAL_AGENT = 'false'

yo wasm
```

### Build and Deploy Our App

```
cargo build --release --target wasm32-wasi
wasmtime ./target/wasm32-wasi/debug/funbytes_live.wasm
hippo push -k .
```

```
# Update source
cargo build --release --target wasm32-wasi
wasmtime ./target/wasm32-wasi/debug/funbytes_live.wasm
hippo push -k .
popd
```

## What is [Krustlet](https://github.com/krustlet/krustlet)?

Krustlet acts as a Kubelet by listening on the event stream for new pods that the scheduler assigns to it based on specific Kubernetes tolerations.

The default implementation of Krustlet listens for the architecture wasm32-wasi and schedules those workloads to run in a wasmtime-based runtime instead of a container runtime.

## Getting Started with Krustlet in AKS (WASM NodePools)

[Based on the preview docs](https://docs.microsoft.com/azure/aks/use-wasi-node-pools?containers-50124-stmuraws)

### Setup Environment

```bash
pushd src/provisioning
./aks_wasm_environment.sh
```

### Get My WASM NodePool Node's IP Address

```
kubectl get nodes -o="jsonpath={range .items[?(@.status.nodeInfo.architecture=='wasm-wagi')]}{.metadata.name}{'\t'}{.status.addresses[?(@.type=='InternalIP')].address}{'\n'}{end}"
```

### Deploy My "Pod"

```bash
kubectl apply -f pod.yml
```

```bash
kubectl get -f pod.yml -o="jsonpath={'Name: '}{.metadata.name}{'\n'}{'State: '}{.status['phase','message']}{'\n'}"
```

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install hello-wasi bitnami/nginx -f values.yml

kubectl get svc hello-wasi-nginx -o="jsonpath={'http://'}{.status.loadBalancer.ingress[0].ip}{'\n'}"
popd
```

## Reference Links

#### [My Blog Series](https://dev.to/smurawski/series/15635)

#### [Dev Environment Repo](https://github.com/smurawski/hippo-dev)

#### [Wasmtime](https://wasmtime.dev/)

#### [WAGI](https://github.com/deislabs/wagi)

#### [Hippo](https://github.com/deislabs/hippo)

#### [Krustlet](https://github.com/krustlet/krustlet)

#### [WASM Node Pools in AKS](https://docs.microsoft.com/azure/aks/use-wasi-node-pools?containers-50124-stmuraws)