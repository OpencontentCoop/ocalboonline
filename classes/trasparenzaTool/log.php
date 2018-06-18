<?php

class LogLine
{
    private $data = array();

    private $recursionLevel = 0;

    public function __construct($recursionLevel)
    {
        $this->recursionLevel = $recursionLevel;
    }

    public function append($message, $level)
    {
        $this->data[] = array(
            'message' => $message,
            'level' => $level
        );

        return $this;
    }

    public function appendNotice($message)
    {
        $this->append($message, 'notice');

        return $this;
    }

    public function appendWarning($message)
    {
        $this->append($message, 'warning');

        return $this;
    }

    public function appendError($message)
    {
        $this->append($message, 'error');

        return $this;
    }

    public function write()
    {
        $cli = eZCLI::instance();
        $prefix = $this->recursionLevel > 0 ? str_pad(' ', $this->recursionLevel * 2, "    ", STR_PAD_LEFT) . '|- ' : '';

        $cli->output($prefix, false);

        $needABeer = true;

        foreach ($this->data as $item){
            if ($item['level'] == 'notice'){
                $cli->notice($item['message'] . ' ', false);
            }elseif ($item['level'] == 'warning'){
                $cli->warning($item['message'] . ' ', false);
                $needABeer = false;
            }elseif ($item['level'] == 'error'){
                $cli->error($item['message'] . ' ', false);
                $needABeer = false;
            }
        }

        if ($needABeer){
            $cli->output("\xF0\x9F\x8D\xBA");
        }else{
            $cli->output();
        }        
    }
}