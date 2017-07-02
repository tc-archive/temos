
# ssh-agent bash
# ssh-add ~/.ssh/id_rsa



# for i in $(cat hostnames.txt)
# do
#     ssh-keyscan $i >> ~/.ssh/known_hosts
# done

alias get-finger-prints='ssh-keyscan server1.example.com >> ~/.ssh/known_hosts'
