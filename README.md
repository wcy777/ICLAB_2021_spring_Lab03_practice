# ICLAB_2021_spring_Lab03_practice
#### Design：Sudoku (SD)
#### Description：
&emsp; State 總共分為四個 (IDLE、READ、CACULATE、OUT)，首先在READ時開始讀入81(9*9)筆輸入，<br>
&emsp; 在讀的過程中總共執行兩件事情，<br>
&emsp; 1. 當遇到輸入為0時(blank)，記住此位置的row address(0~8)、column address(0、9、18、27、...)、<br>
&emsp;&emsp; grid address(0、3、6、9、12、...).<br>
&emsp; 2. 在讀入的過程中也不斷的在比較輸入的值是否有違反數獨的規定(輸入為不可解的pattern).<br>
&emsp; 當輸入完後進到CALAULATE state，在這個state中從第一個blank的位置及數值從1開始往上開始去比較，<br>
&emsp; 當數值為可存在時，到下一個位置繼續比較，當都沒有數值可存在時，歸0並回到上一個blank位置，從上一<br>
&emsp; 個blank位置目前的數值再往上做比較，以此類推，當不存在一組數值滿足所有blank或是以找出所有數值，<br>
&emsp; 就進入到OUT state 輸出output.<br>

&emsp; 若在輸入階段就發現無解的pattern 在剛進入CACULATE state就會直接跳到OUT state 輸出output.
