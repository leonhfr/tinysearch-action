# tinysearch action

tinysearch-action is a Github action to build a [tinysearch](https://github.com/tinysearch/tinysearch) engine from an index file. This action is meant to be combined with static site generators (Hugo, mdBook, ...).

This example takes a json index located in `public/index.json` and outputs all `wasm` and `js` files to the `static/wasm` directory.

```yaml
- name: Build tinysearch
  uses: leonhfr/tinysearch-action@master
  with:
    index: public/index.json
    output_dir: static/wasm
    output_types: |
      wasm
      js
```

## Usage

### Inputs

```yaml
- uses: leonhfr/tinysearch-action@master
  with:
    # Path to the json index.
    index: public/index.json # default
    # Path to the output directory.
    # If the directory does not exist, it will be created.
    output_dir: static/wasm # default
    # Extensions that will be copied from the tinysearch output to the output directory.
    # This should be a multiline input using the pipe operator |, with one extension per line.
    output_types: | # default
      wasm
      js
```

The `tinysearch` command outputs those files:

```sh
$ ls wasm_output
demo.html                      # search demo
package.json                   # metadata
storage                        # no clue what this is but we don't use it
tinysearch_engine.d.ts         # library typescript types
tinysearch_engine.js           # library to initiate and call the tinysearch wasm
tinysearch_engine_bg.wasm      # tinysearch engine asm
tinysearch_engine_bg.wasm.d.ts # wasm typescript types
```

Most of the time, we're only interested in the actual wasm engine (`tinysearch_engine_bg.wasm`) and the Javascript glue library (`tinysearch_engine.js`). By default, only those files will be copied to the output directory.

The `demo.html` file is useful to have an implementation example for reference.

### Outputs

In addition to copying the specified file extensions to the output directory, the action outputs the list of copied files to be used in following steps. This is useful for example if some files have to be moved to other directories.

For example, the last step will echo file names:

```yaml
- uses: actions/checkout@v3
- name: Build tinysearch
  id: tinysearch
  uses: leonhfr/tinysearch-action@master
- name: List emitted files
  run: |
    echo ${{ steps.tinysearch.outputs.files }}
```

## Scenarios

Only the scenario I'm using this action is listed at the moment, but any [contributions](https://github.com/leonhfr/tinysearch-action/blob/master/CONTRIBUTING.md) with how you're using this action are welcome.

### Deploy a Hugo website to Github pages

(Tutorial [source](https://github.com/tinysearch/tinysearch/blob/master/howto/hugo.md) in the tinysearch repository.)

With Hugo, the index can be built by adding a custom JSON layout:

```json
[
  {{ range $index , $e := .Site.RegularPages }}{{ if $index }}, {{end}}{{ dict "title" .Title "url" .Permalink "body" .Plain | jsonify }}{{end}}
]
```

Then, the `config.toml` has to be updated to also output JSON:

```toml
# ...

[outputs]
    home = ["html","rss","json"] # Add json to the list

# ...
```

The index file will be in `public/index.json` (hence the action default).

Finally, use the action after building the hugo website and before publishing:

```yaml
- uses: actions/checkout@v3
- name: Setup Hugo
  uses: peaceiris/actions-hugo@v2
  with:
    hugo-version: '0.104.2'
- name: Build website
  run: hugo
  env:
    HUGO_ENV: production
- name: Build tinysearch
  uses: leonhfr/tinysearch-action@master
  with:
    output_dir: static/wasm
    output_types: |
      wasm
- name: Deploy
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_branch: gh-pages
    publish_dir: ./public
```

## Testing

The example index in `fixtures/index.json` has been copied from the [tinysearch](https://github.com/tinysearch/tinysearch) repository.

To test this repository locally using [act](https://github.com/nektos/act) and the `test.yaml` workflow, run:

```sh
# removing previous container to force rebuild test any changes
$ docker rmi act-dockeraction ; act -v
```

## License

The scripts and documentation in this project are released under the [MIT License](https://github.com/leonhfr/tinysearch-action/blob/master/LICENSE).
