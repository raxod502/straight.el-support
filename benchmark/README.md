**`straight.el` benchmarks**

These benchmarks are, of course, approximate. They'll be made more
professional over time.

## Install and load packages

|              | `straight.el` | `package.el` |
| ------------ | ------------- | ------------ |
|  25 packages |        179.7s |        46.7s |

## Load packages (already installed)

|              | `straight.el` | `straight.el` (live checking) | `package.el` |
| ------------ | ------------- | ----------------------------- | ------------ |
|  25 packages |        560ms  |                         430ms |        313ms |

## Running the benchmarks yourself

Start Emacs with `.emacs.d` set to this directory. I recommend
including the following code at the beginning of your init-file, so
that you can do this easily to switch between Emacs configurations:

    (let ((alternate-user-emacs-directory (getenv "USER_EMACS_DIRECTORY")))
      (if alternate-user-emacs-directory
          (progn
            (setq alternate-user-emacs-directory
                  (file-name-as-directory alternate-user-emacs-directory))
            (setq user-emacs-directory alternate-user-emacs-directory)
            (setq user-init-file (expand-file-name "init.el" user-emacs-directory))
            (load user-init-file 'noerror 'nomessage))
        ;; your normal init goes here
        ))

The benchmarks are controlled using command-line flags.

### Command line flags

*Which package manager to test, defaults to `straight.el`*

    --backend (straight | package)

*How many packages to install/load, defaults to 25 (the list is in
`packages.el`)*

    --package-count NUMBER-OF-PACKAGES

*By default, packages are assumed to be installed and they are only
loaded. You can instead cause all packages to be removed and benchmark
the installation + loading process*

    --install | no-install

*For `straight.el`, live modification checking is disabled by
default.*

    --live | --no-live

## Disclaimer

I am not responsible if this accidentally deletes your hard drive
because I messed up a `delete-directory` somewhere.
