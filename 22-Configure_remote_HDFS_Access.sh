cat > ~/sas_viya_playbook/remote_hdfs.ini << EOF
sascas01 ansible_host=intcas01.race.sas.com
sascas02 ansible_host=intcas02.race.sas.com
sascas03 ansible_host=intcas03.race.sas.com
sashdp01 ansible_host=sashdp01.race.sas.com
sashdp02 ansible_host=sashdp02.race.sas.com
sashdp03 ansible_host=sashdp03.race.sas.com
sashdp04 ansible_host=sashdp04.race.sas.com

[casnodes]
sascas01
sascas02
sascas03

[hdpnodes]
sashdp01
sashdp02
sashdp03
sashdp04
EOF
cat > /tmp/insertHDPHostsBlock.yml << EOF
---
- hosts: casnodes,localhost
  tasks:
  - name: Remove any existing previous sashdp reference
    lineinfile:
      path: /etc/hosts
      state: absent
      regexp: 'sashdp'
  - name: Insert HDP Hosts block for remote CAS access
    blockinfile:
      path: /etc/hosts
      backup: yes
      insertafter: EOF
      block: |
        10.96.10.203 sashdp02.race.sas.com sashdp02
        10.96.5.139 sashdp04.race.sas.com sashdp04
        10.96.14.73 sashdp01.race.sas.com sashdp01
        10.96.14.5 sashdp03.race.sas.com sashdp03
EOF
cd ~/sas_viya_playbook
ansible-playbook /tmp/insertHDPHostsBlock.yml  -i remote_hdfs.ini --diff -b
cat > /tmp/setviyademo01privkey.yml << EOF
---
- hosts: casnodes
  gather_facts: false
  become: yes
  become_user: root

  tasks:
  - name: ensure .ssh folder exists
    file:
      path: "{{ homedir }}/viyademo01/.ssh/"
      state: directory
      mode: '0700'
      owner: viyademo01
    tags:
      - dotsshfolder

  - name: ensure the id_rsa file exists
    file:
      path: "{{ homedir }}/viyademo01/.ssh/id_rsa"
      state: touch
      mode: '0700'
      owner: viyademo01
    tags:
      - idrsatouch

  - name: Insert private key in the id_rsa
    blockinfile:
      path: "{{ homedir }}/viyademo01/.ssh/id_rsa"
      backup: yes
      insertafter: BOF
      block: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpQIBAAKCAQEA6S7Kbp2tZXU+1NUz93yBV6Yd3C/djuGxUUeVyC6j6CN9H2eZ
        4gf7LZM7kkexA8/XawMIphHFVnlsz+S4UQAvzIEyhR60MoJfV5FbDcc5vS9xu+YJ
        HSgPDkWfJybTIEWG4bWrpmqA26sqpbKuMTOqoDMJSA4OsGMjErfIG3k7VF5adTm4
        f+oeFwWIuV2c5m6LY6TSvWmVbEiPiSYs9UELuu8jNp7tkd9IYYorTkiVu2WpHfkZ
        yZDNLrwndQLWDG9tKFbvoF8+Xb8pvqSa/gTn7OM/4z3f03oPL2GYKovePmssl15O
        0Sb0FeGoU8ubvSsePBZXG+TMnpZf0XS0K4qr4QIDAQABAoIBAQCOfuKD4GVi99gS
        lcsw9OvRlRjwQmvhcbg7FETK1P2i0XUX6OaXwwrSmgOwa5EX5D4fDfaODZQLOR6u
        mHWuQi/ziAxIXy/9IcCDsbbz34hAPSsCiRuOrrksno0Yjtg8A2Des3cWtkTSeHIS
        WfOq64jcZvPIDZcaYSrAuIBXkakY73jxqZArRSUQQj6ZqyEFpUdhAFfqYiylHS4p
        kOSJRpVL4mwdYsLOCDI5vvAwhu1kcZYaJ4FylFvF2Y+LHoursLg1X2+qg0E/Zy3h
        OnVl242orRN3X9D+tTcxsctFND5EqVm6NDpnPjZddVC5LM6yQWbqfBH5ddd2sJrv
        WLiSr0WFAoGBAP8XSxgnVhkFn/S+o8sC+355/je+Xl75oNrLdnrqlNew7FpGLPNX
        LdpYYtNmUyUxT+C3PR6WLvv1flYvbpIp1hbE6r+hekwIIb6flqvW2cazsVdJdJqB
        EkiFfcuZ0BZcY1xmVhsqqRgaVNIDTK2Knrm1CQ8Pka1o+FeQDhHvqNO/AoGBAOoD
        gvu5H59l3goU6PBD+CD9HD9afVaa43bzESS495oF7zmSC+Suvi/cB8KVABvQsXEC
        XE5JHD4eiGlc298hWTFTc2qx/z04jAepthHfjQkL+NhEDxv5V4i+RkiRK9oH6bdn
        0dHXPADXi4t3I7VotWj/E+aaPqyBRKjJ6g6nwehfAoGAcARfkpS7hzNkIYqRzLVb
        kRerHfl34YcHLu1H8wQOJoVn1OCaHqW62fYUN7bobh2wcQKmUUcsDLKqLtiXWpIK
        lGcWmt4jIT4060uTU5R+f3YrOyRjkvF5AOW17vF1YkxhyZKa30UlihMOCkcupcqI
        lw47kySIGTlOTM1SkGfIoGsCgYEA3fdUv5W55ATI1sE8reGasxfCOmmHp6UlCsfF
        xBJacVMdtXrNIy2IonbPOYcBYmDSXkIB8hOw4U8uztnQiFXmdz4TpOmPE6/WStJ0
        K4HjEei0MdZkioE4wTDSE7T3ZkjJLDkisSq59IZ/C1uHmGPoZt5ELyCxQAkhagST
        qTEAYXsCgYEA2KN9sR1uczkBvhgVK4ZmEC7NJJ8tKIWEH94SbNtXxiWwWvw7kDV5
        oDI53t7QUmHX4fT0lRiNzxeqWpYdbrUrF6LAV7Gc4iaTGUkrmmJT4YNJwzpqezP7
        FIkDXGmey4nhYP/EhnYJvlLWoxzPpGg/P/1TknvLXEv3CElJigb6jxg=
        -----END RSA PRIVATE KEY-----
    tags:
      - insertkeyinfile
EOF
cd ~/sas_viya_playbook
ansible-playbook /tmp/setviyademo01privkey.yml -i remote_hdfs.ini -e "homedir=/sharedhome" -b
ansible casnodes -i remote_hdfs.ini -m shell -a "for h in sashdp0{1..4};do ssh -o \"StrictHostKeyChecking=no\" \$h \"whoami;hostname -f\" ;done" --become-user viyademo01 -b
# Ensure name=sas-viya-sasstudio-default is up and running.
cd ~/sas_viya_playbook
ansible programming -m service -a "name=sas-viya-sasstudio-default state=started" -b
