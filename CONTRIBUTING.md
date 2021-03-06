# How to Contribute

Worldcon is a community brought together to celebrate science fiction. Without community, this event wouldn't be great.
Just like the con itself, we need helpers and contributors like you to make this stuff work.

We want to keep it as easy as possible to contribute changes that get things working in your environment. There are a
few guidelines that we need our contributors to follow so that we can have a chance of keeping on top of things.

## Getting started: Forking the project

1. Make sure you have a [Gitlab account](https://gitlab.com/users/sign_in#register-pane)
2. Check the [list of issues](https://gitlab.com/worldcon/wellington/issues) to see if there's already a
   conversation about your feature/bug
3. If there's nothing there, [raise a new issue](https://gitlab.com/worldcon/wellington/issues/new) with the
   as much detail as you can, including
    - a clear description of the issue,
    - when it is a bug, steps to reproduce the behaviour,
    - information about the  application version and operating system,
    - note, a ticket is not necessary for trivial changes.
4. [Fork the project](https://gitlab.com/worldcon/wellington/forks/new) on Gitlab, make changes if you can or just
   a test if you can't.

## Making changes: Committing and sharing

* Create a topic branch from where you want to base your work.
    * This is usually the master branch.
    * Only target release branches if you are certain your fix must be on that branch.
    * Please avoid working directly on the master branch.
    * To quickly create a topic branch based on master, run
      ```
      git checkout -b my_sweet_feature origin/master
      ```
* Make commits of logical and atomic units. Ideally, no commit should break tests.
* Write tests for your work. They need not be exhaustive, but they do need to describe the behaviour of our application.
  Find examples of other specs in the [spec directory](spec).
* Do check your files against this project's linting rules.
  For Ruby we use `rubocop` with the [RuboCop GitHub](https://github.com/github/rubocop-github) rules,
  and `eslint` against the [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript).
  It's recommended that you get an editor plugin
  [for rubocop](https://docs.rubocop.org/en/latest/integration_with_other_tools/)
  and [for eslint](https://eslint.org/docs/user-guide/integrations)
  for quick feedback as you work.
* [Mention any issues](https://gitlab.com/worldcon/wellington/issues) relating to your change in your commit
  messages. For example
  ```
  issue #1: Rework guide, move OSX specific instructions into it's own file
  ```
* Trivial changes that are not specific to issues don't need this. Please instead mention "docs", "maint", "bugfix", or
  "packaging" as appropriate. For example
  ```
  docs: Rework guide, move OSX specific instructions into it's own file
  ```

## Licensing: Legal stuff that helps us share our work

This project is distributed under the Apache license. We do this because it's an open license that allows us to release
our work without worrying about legal liability, patient infringement and other stuff that gets in the way of writing
code for our convention.

To do this, we need to maintain some boilerplate text in our files.

New contributors should add their name to the [LICENSE](LICENSE) file in the root of this project, and the
[README.md](README.md). Try put your name in alphabetical order, and mention the current year.

Where there are multiple authors please try keep them sorted by year, then alphabetically.

If you're creating a new file in this project, please add the following boilerplate comment in the top to declare the
licence that file is under:

> Copyright [year] [author name]
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>   http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.

There are CI scripts running to ensure that the license header is in place in all relevant files. To verify this locally, you can run these commands:

```
# For docker developers
docker-compose exec -T members_area bundle exec rake test:branch:copyright

# For system ruby developers
bundle exec rake test:branch:copyright
```
