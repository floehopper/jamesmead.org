---
title: Organisation-specific git authentication and commit signing
description: Using SSH keys stored in 1Password on MacOS
created_at: 2026-04-19 10:13:00 +01:00
updated_at: 2026-04-19 10:13:00 +01:00
guid: b3bc505e-934c-4a37-a694-e171e76bad03
---

Recently I wanted to use a separate SSH key for work on repositories in a specific GitHub organisation, but continue to use a single GitHub user account. I already had [some organisation-specific git configuration](/blog/2018-09-06-organisation-specific-git-config) which sets the email address used in commit notes and I've now managed to extend that to incorporate using an organisation-specific SSH key both for authentication with GitHub and for signing my commits.

One complication was that I wanted to continue to manage my SSH keys in 1Password which I use as my [SSH agent](https://developer.1password.com/docs/ssh/agent/). I struggled to find a way to make the 1Password SSH agent offer the correct organisation-specific key, but eventually worked out that I could set [`core.sshCommand`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-coresshCommand) in my organisation-specific git config to override the default `ssh` command and specify the relevant public key using the `-i` (identity file) option. Although this feels like a bit of a hack, the only downside I can see is that I had to export each of the public keys to my `~/.ssh` directory which effectively introduces duplication, but it's duplication that I can live with.

While testing this configuration I came across the [`gpg "ssh".allowedSignersFile`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgsshallowedSignersFile) git configuration option which means you can use `git log --show-signature` to check your commits have been signed correctly.

## 1Password configuration

[Using these instructions](https://developer.1password.com/docs/ssh/manage-keys/#generate-an-ssh-key):

* Generate an [Ed25519] SSH key for organisation 1
* Generate an [Ed25519] SSH key for organisation 2

And then download the public key for each to:

* `~/.ssh/github-organisation-1.pub`
* `~/.ssh/github-organisation-2.pub`

## GitHub configuration

### Emails

In [your GitHub email settings](https://github.com/settings/emails):

* Add & verify `email.address@organisation-1.com`
* Add & verify `email.address@organisation-2.com`

### SSH keys

In [your GitHub SSH key settings](https://github.com/settings/ssh/):

* Add SSH key for organisation 1 as authentication key
* Add SSH key for organisation 2 as authentication key
* Add SSH key for organisation 1 as signing key
* Add SSH key for organisation 2 as signing key

## SSH configuration

Configure ssh to use 1Password as its agent. And list allowed signers for each organisation to be used as `allowedSignersFile`.

<pre>
  <code>
    # ~/.ssh/config
    Host *
      IdentityAgent &lt;path-to-1password-agent.sock&gt;

    # ~/.ssh/allowed_signers_for_organisation_1
    email.address@organisation-1.com ssh-ed25519 &lt;ssh-public-key-for-organisation-1&gt;

    # ~/.ssh/allowed_signers_for_organisation_2
    email.address@organisation-2.com ssh-ed25519 &lt;ssh-public-key-for-organisation-2&gt;
  </code>
</pre>

## Git configuration

### Shared

* [Sign commits using SSH keys in 1Password](https://developer.1password.com/docs/ssh/git-commit-signing)
* [Include organisation-specific configurations](/blog/2018-09-06-organisation-specific-git-config)

<pre>
  <code>
    # ~/.gitconfig
    [gpg]
      format = ssh
    
    [gpg "ssh"]
      program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
    
    [commit]
      gpgsign = true
    
    [includeIf "gitdir:~/Code/organisation-1/**"]
      path = ~/.config/git/organisation-1.inc
    
    [includeIf "gitdir:~/Code/organisation-2/**"]
      path = ~/.config/git/organisation-2.inc
  </code>
</pre>

### Organisation 1

* Use SSH key for organisation 1 to authenticate with GitHub
* Use SSH key for organisation 1 to sign commits
* Specify allowed signers for organisation 1 (used by e.g. `git log --show-signature`)

<pre>
  <code>
    # ~/.config/git/organisation-1.inc
    
    [user]
      email = email.address@organisation-1.com
      signingkey = ssh-ed25519 &lt;ssh-public-key-for-organisation-1&gt;
    
    [core]
      sshCommand = "ssh -i ~/.ssh/github-organisation-1.pub"
    
    [gpg "ssh"]
      allowedSignersFile = ~/.ssh/allowed_signers_for_organisation_1
  </code>
</pre>

### Organisation 2

* Use SSH key for organisation 2 to authenticate with GitHub
* Use SSH key for organisation 2 to sign commits
* Specify allowed signers for organisation 2 (used by e.g. `git log --show-signature`)

<pre>
  <code>
    # ~/.config/git/organisation-2.inc
    [user]
      email = email.address@organisation-2.com
      signingkey = ssh-ed25519 &lt;ssh-public-key-for-organisation-2&gt;
    
    [core]
      sshCommand = "ssh -i ~/.ssh/github-organisation-2.pub"
    
    [gpg "ssh"]
      allowedSignersFile = ~/.ssh/allowed_signers_for_organisation_2
  </code>
</pre>

[Ed25519]: https://en.wikipedia.org/wiki/EdDSA#Ed25519
