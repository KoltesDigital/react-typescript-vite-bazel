# React + TypeScript + Vite, the Bazel way

Port of the [React + TypeScript + Vite template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) (using SWC) to Bazel 8.

As an example, includes rules to build an OCI image serving the built files with a tiny static HTTP server.

However, instead of building a new image for every change, consider uploading the built files into a OCI/K8S volume served by a static server container, to a simple webhosting server, to an S3 bucket, either public or behind a CDN, etc. Advantage: faster update. Drawback: non-atomicity.

Also consider excluding `react` and `react-dom` from the build and including them from a CDN. Advantages: faster build, lighter artifacts, hopefully faster client retrieval. Drawbacks: reliance on the CDN availability, different update process.

## Usage

Run development server with hot-reload:

```sh
bazel run //:dev
```

Run non-production static server with built files:

```sh
bazel run //:preview
```

Run minimal production server (assuming `docker` runtime):

```sh
bazel run //:load
docker run --rm -p 8043:8043 react-typescript-vite
```

Build and get path to build directory, e.g. to upload its files somewhere:

```sh
bazel build //:build
bazel cquery --output=files //:build
```

Run tests (ESLint, TSC type checks):

```sh
bazel test //...
```

Manage Node.js dependencies using Bazel-provided `pnpm`:

```sh
bazel run @pnpm -- --dir $PWD install ...
```

## Limitations

Aspect rules are not compatible with Windows, but they work within WSL.

## License

Public domain / CC0
