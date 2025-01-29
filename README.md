# React + TypeScript + Vite, the Bazel way

Port of the [React + TypeScript + Vite template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) (using SWC) to Bazel 8.

Note: [`ibazel`](https://github.com/bazelbuild/bazel-watcher) is required for development hot-reload.

Let's be honest: you've searched this template because you love developing frontends with Vite AND you love generating files from any programming language with Bazel AND you'd love your Bazel-generated files to be part of your Vite workflow. Say no more and head to the `monorepo` branch!

After a successful build, upload the files into a OCI/K8S volume served by a static server container, to a simple webhosting server, to an S3 bucket, either public or behind a CDN, etc. Note that this update is not atomic and it may be a problem if the upload takes some time. Check the `oci` branch out for rules to build an OCI image serving the built files with a tiny static HTTP server.

Consider excluding `react` and `react-dom` from the build and including them from a CDN. Advantages: faster build, lighter artifacts, hopefully faster client retrieval. Drawbacks: reliance on the CDN availability, different update process. Check the `cdn` branch out.

## Usage

After initial clone, and after each Node.js dependency change, install them and refresh lock using Bazel-provided `pnpm`:

```sh
bazel run '@pnpm' -- --dir $PWD install
```

Well, that's how you'll run `pnpm`: replace `install` by other commands like `add ...`, `update`, etc.

But for now, run the development server with hot-reload:

- Linux:

  ```sh
  nohup ibazel build //:dev > /dev/null 2>&1 & ; bazel run //:dev ; kill $!
  ```

- Windows:

  ```powershell
  $p = Start-Process -WindowStyle Hidden ibazel 'build //:dev' -PassThru ; try { bazel run //:dev } finally { $p.Kill() }
  ```

Build and get path to the build directory, e.g. to upload its files somewhere:

```sh
bazel build //:build
bazel cquery --output=files //:build
```

Run the preview server (serving built files, not meant for production):

```sh
bazel run //:preview
```

Run all tests (ESLint, TSC type checks):

```sh
bazel test //...
```

## Some explanations

There certainly are multiple ways to integrate Bazel with Vite. On this project, I've taken the following path: Bazel does its job, present Vite files in the way it expects them, and then Vite can do its job too.

Running servers (`vite` / `vite preview`) are long-standing operations, and best match `bazel run`. Such processes are run in their own directory with appropriate runfiles. While it's fine for the preview server, as built files are served, it doesn't play well with the dev server. Vite sources are copied to `bazel-bin/`, and then symlinked to `bazel-bin/dev_/dev.runfiles/_main/` (the initial working directory of `bazel run //:dev`). If, say, `src/main.tsx` is changed, and `bazel build //:dev` is run, while another `bazel run //:dev` is spinning, `bazel-bin/src/main.tsx` and therefore `bazel-bin/dev_/dev.runfiles/_main/src/main.tsx` will change too, but the running dev server will detect change only to `bazel-bin/src/main.tsx` because it follows symlinks, so it doesn't hot-reload the changes.

Not following symlinks means Vite would watch changes to the symlink itself, not the file it targets. However, Bazel will create symlinks in the runfiles directory only when running a new `bazel run //:dev`, and moreover will happily keep existing symlinks, most of the time.

So the working trick, [as hinted by another repo](https://github.com/mikberg/bazel-vite), is to play with Node.js process' working directory before actually entering the Vite entrypoint. Improvement to the hint has been to keep the process' working directory in `bazel-bin/`, therefore letting Bazel the ability to generate source files.

The other rules are rather self-explanatory.

Like for the original template, `tsc` is used for validation only, however the code is split between two environments. With Bazel we can be more specific regarding the files including in each one. Besides, SWC has its own configuration format, so each `tsconfig` must be translated. That's what the `type_check` macro does.

## Limitations

Beware of server lock! For instance if you're using VS Code with the Bazel extension, the latter will query the targets after any file has been saved, thus blocking `ibazel` and delaying Vite hot-reload for several seconds. To avoid that, add `"bazel.queriesShareServer": false` to your settings.

## License

Public domain / CC0
