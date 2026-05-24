function gs --wraps 'git status' --description 'Git status with short branch format'
    git status -sb $argv
end
