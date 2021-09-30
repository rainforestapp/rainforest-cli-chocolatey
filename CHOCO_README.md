# rainforest-cli

A command line interface to interact with [Rainforest QA](https://www.rainforestqa.com/). Source, and more documentation is [availble here](https://github.com/rainforestapp/rainforest-cli#basic-usage)

## Global Options

- `--token <your-rainforest-token>` - your API token if it's not set via the `RAINFOREST_API_TOKEN` environment variable
- `--skip-update` - Do not automatically check for CLI updates

## Options

- `--browsers ie8,chrome` - specify browsers you wish test. This overrides the test level settings. Valid browsers can be found in your account settings.
- `--tag TAG_NAME` - filter tests by tag. Can be used multiple times for filtering by multiple tags.
- `--site-id SITE_ID` - filter tests by a specific site. You can see a list of your site IDs with `rainforest sites`.
- `--folder ID/--filter ID` - filter tests in specified folder.
- `--feature ID` - filter tests in a feature.
- `--run-group ID` - run/filter based on a run group. When used with `run`, this trigger a run from the run group; it can't be used in conjunction with other test filters.
- `--environment-id` - run your tests using this environment. Otherwise it will use your default environment
- `--conflict OPTION` - use the `abort` option to abort any runs in progress in the same environment as your new run. use the `abort-all` option to abort all runs in progress.
- `--bg` - creates a run in the background & exits immediately after. Cannot be used together with `--max-reruns`.
- `--crowd [default|automation|automation_and_crowd|on_premise_crowd]`
- `--wait RUN_ID` - wait for an existing run to finish instead of starting a new one, and exit with a non-0 code if the run fails. rainforest-cli will exit immediately if the run is already complete.
- `--fail-fast` - return an error as soon as the first failed result comes in (the run always proceeds until completion, but the CLI will return an error code early). If you don't use it, it will wait until 100% of the run is done.
- `--custom-url` - specify the URL for the run to use when testing against an ephemeral environment. Temporary environments will be automatically deleted 72 hours after they were last used.
- `--description "CI automatic run"` - add an arbitrary description for the run.
- `--release "1a2b3d"` - add an ID to associate the run with a release. Commonly used values are commit SHAs, build IDs, branch names, etc.
- `--junit-file` - Create a junit xml report file with the specified name. Must be run in foreground mode, or with the report command.
- `--import-variable-csv-file /path/to/csv/file.csv` - Use with `run` and `--import-variable-name` to upload new tabular variable values before your run to specify the path to your CSV file.
- `--import-variable-name NAME` - Use with `run` and `--import-variable-csv-file` to upload new tabular variable values before your run to specify the name of your tabular variable.
- `--single-use` - Use with `run` or `csv-upload` to flag your variable upload as `single-use`. See `--import-variable-csv-file` and `--import-variable-name` options as well.
- `--disable-telemetry` stops the cli sharing information about which CI system you may be using, and where you host your git repo (i.e. your git remote). Rainforest uses this to better integrate with CI tooling, and code hosting companies, it is not sold or shared. Disabling this may affect your Rainforest experience.
- `--max-reruns` - If set to a value > 0 and a test fails, the CLI will re-run failed tests a number of times before reporting failure. If `--junit-file <filename>` is also used, the JUnit reports of reruns will be saved under `<filename>.1`, `<filename>.2` etc.

## Support

Email [help@rainforestqa.com](mailto:help@rainforestqa.com) if you're having trouble using the CLI or need help with integrating Rainforest in your CI or development workflow.