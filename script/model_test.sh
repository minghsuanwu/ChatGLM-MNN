model_test() {
    echo 'test model: ' $1
    ./script/download_model.sh $1
    cd build
    # linux
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
    # macos
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:.
    ./cli_demo -m ../$1
    cd ..
}

test_all() {
    model_test chatglm-6b
    model_test chatglm2-6b
    model_test chatglm3-6b
    model_test codegeex2-6b
    model_test qwen-7b-chat
    model_test baichuan2-7b-chat
    model_test llama2-7b-chat
}

if [ $1 -eq 'all' ]; then
    test_all
else
    model_test $1
fi