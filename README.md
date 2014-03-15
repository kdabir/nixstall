nixstall
========

Generic installer for **\*nix** platform for the packages are *not* listed in your favourite package manager.

Install just about anything from the url using the following command:

    nixstall get http://somesite.com/package-1.2.3.zip

Or from the local filesystem using:

    nixstall /path/to/package-1.2.3.zip


If it's the *first* time you are using `nixstall`, then use:

    curl -L http://git.io/nixstall | bash -s get http://somesite.com/somepackage-1.2.3.zip


## Features

- Download and install archive from remote url or from local filesystem

- Install any standard package that has `bin` directory

- `nixstall` manages itself automatically. You don't even need to install it.

- Developers can distribute the snippet like the following for their packages as installer.
        `curl -L http://git.io/nixstall | bash -s get http://yoursite.com/yourpackage-1.2.3.zip`

- Don't need to wait for the maintainer to update the package in package manager.

- `PATH` managed automatically


## Why?

Most packages follow a simple structure

    + archive(.zip)
    |--+ package-v1.0.2/
    |  |--+ bin/
    |  |--+ lib/
    |  |--+ whatever/
    |  ..

But Installation requires atleast three steps:

1. Download a `.zip`,
2. Extract it,
3. And then set the path to its `bin` directory in `PATH` environment variable in `.*rc` / `.*profile` files.

The last step is quite error prone. Do you see a pattern? These three steps can be automated into one.
And that's just what nixstall does well. No more pesky `PATH` editing.


## User guide

Let's install Ant. We know it lives [here](http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.3-bin.zip)

    curl -L http://git.io/nixstall | bash -s get http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.3-bin.zip

This installs ant and in fact install nixstall as well. Now next time on you can use `nixstall` command directly and it all
gets even terse when you use `nixstall` that's already there on your machine now:

1. Installing nixstall **itself**. Nixstall installs itself whenever you install any package for the first time. But if you
   want to install nixstall first :

        curl -L http://git.io/nixstall | bash -s self

2. Getting archive directly from the site:

        nixstall get http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.3-bin.zip

3. Some archive that's already there on your machine:

        nixstall /path/to/apache-ant-1.9.3-bin.zip

4. From already extracted dir:

        nixstall_link /path/to/ant-1.9.3

    This just creates symlink and does not copy content.

5. Listing paackages installed

        nixstall_link

6. Reloading path when new package is installed without opening new terminal

        nixstall_reload

7. Updating nixstall

        nixstall self


> Note: Ant can be, of course, installed with other package managers. I have chosen `ant` as an example because most of
> us know it and its binaries are small enough to be downloaded.


## Limitations

- Archives must follow standard structure i.e. they must have `bin` directory in them.
- Archives must be self contained. No post processing is supported.
- You can potentially install multiple versions of same package, and all may end up in PATH

## Troubleshooting

- If the `nixstall` script or shell functions are not loaded for some reason, try:
    `source ~/.nixstall/nixstall/bin/nixstall`

- If that does not exist, try one `curl -sL http://git.io/nixstall | bash -s self`
