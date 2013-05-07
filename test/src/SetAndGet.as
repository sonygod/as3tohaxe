/**
 * Created with IntelliJ IDEA.
 * User: p5
 * Date: 13-5-7
 * Time: 上午11:07
 * To change this template use File | Settings | File Templates.
 */
package
{




public class SetAndGet
{
    private var _vlaue:String
      private var _nice:int;

    private var _nice2:int;
    public function SetAndGet()
    {

    }
    
    public function get vlaue():String
    {
        return _vlaue;
    }
    public function set vlaue(value:String):void
    {
        _vlaue = value;
    }
    public function get nice():int
    {
        return _nice;
    }
    public function set nice2(value:int):void
    {
        _nice2 = value;
    }
}
}
