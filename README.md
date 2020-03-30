# dpretty

Clean up your commits!

This tool is designed to resolve the conflicts between some conflicting goals:

1. A clean git history is one of the best ways to make your code readable, understandable, and reviewable.
   - Therefore, each commit should do one thing and one thing only.
   - _One of the best places to start improving your git commits is with good messages -- [Chris Beams has some great advice](https://chris.beams.io/posts/git-commit/). Making an effort to have good messages will encourage you to have commits that have clearly defined purposes too!_
2. Automatic code formatting also improves the readability of you changes, but:
   - When your editor automatically formats your code, your commits generally are a combination of your functional changes, and the non-functional formatting changes

# Warnings

Dpretty is extremely experimental. No guarantees are provided. If it breaks, you get to keep all the pieces. It does work reasonably hard to protect your changes in the event of a failure -- but don't be surprised if that fails. `git reflog <branch>` can also be really helpful in recovering all sorts of problems, related to dpretty or not.

As with all things software, have a backup strategy for things you care about.

That said, the author is using it regularly, and loving it.

# Requirements

Dpretty should work with podman or docker.

# Usage

Get it:

```
$ git clone https://github.com/nickurak/dpretty.git
```

Use it:

```
$ cd ~/src/<my-project-git-repo>
$ <path-to-dpretty-checkout>/dpretty -r origin/master..HEAD
```

# Details

Dpretty seeks to solve the above challenges by recreating a range of git commits, as if you'd never made a formatting mistake!

It does this in two steps:

1. Examining what files are changed in that range, and automatically reformatting the files, so they're fine _before_ your changes start
2. Recreating each commit in your range on top of it, applying the reformatting rules to each as it goes.

Dpretty is a wrapper around an included tool called git-rapply, which performs that logic of applying a change to a range of commits. It was originally designed to remove the output from Jupyter cells commit-by-commit before code gets incorporated into a shared repository. In that case, it was common to see a huge amount of data show up it output cells, only for someone to eventually delete them in a later commit, meaning the incorrect bloated commits still remained in the repository.

Likewise, workflows that introduce formatting issues, only to remove them in a later commit, mean the formatting issues remain in your history.

In either case, commits having a mixture of functional and non-functional changes makes them harder to understand, and harder to review.

Dpretty relies on other code-formatting tools to do its job. Right now it's rigged to use the `black` formatter for python code, and the `prettier` formatter for various web-facing files (HTML, JS, JSX/React, Markdown JSON). It's not exactly configurable in this regard, but you can see and edit the logic in `dpretty.sh`.

(If you're wondering about the name: Right now, the `d' is for`docker`, because part the goal here is to make this work without you needing to install much software via pip, npm, etc).
