/**
 * Created with IntelliJ IDEA.
 * User: p5
 * Date: 13-5-7
 * Time: 上午11:07
 * To change this template use File | Settings | File Templates.
 */
class SetAndGet {
	@:isVar var vlaue(get, set) : String;
	@:isVar var nice(get, never) : Int;
	@:isVar var nice2(never, set) : Int;

	var _vlaue : String;
	var _nice : Int;
	var _nice2 : Int;
	public function new() {
	}

	function get_vlaue() : String {
		return _vlaue;
	}

	function set_vlaue(value : String) : String {
		_vlaue = value;
		return value;
	}

	function get_nice() : Int {
		return _nice;
	}

	function set_nice2(value : Int) : Int {
		_nice2 = value;
		return value;
	}

}

