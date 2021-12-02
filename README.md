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



## What is [Hippo](https://github.com/deislabs/hippo)?

## Getting Started with Hippo in Azure

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
