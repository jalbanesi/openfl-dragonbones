package ilmare.dragonbones.factorys;

/**
 * ...
 * @author Juan Ignacio Albanesi
 */
class FactoryManager
{
	var _factories: Map<String, BaseFactory>;
	
	public function new() 
	{
		_factories = new Map<String, BaseFactory>();		
	}
	
	public static var instance(get, never): FactoryManager;
	static var _instance: FactoryManager = null;
	
	static function get_instance(): FactoryManager
	{
		if (_instance == null)
			_instance = new FactoryManager();
		return _instance;
	}
	
	public function addFactory(name: String, factory: BaseFactory): Void
	{
		_factories.set(name, factory);
	}
	
	public function getFactory(name: String): BaseFactory
	{
		if (_factories.exists(name))
		{
			return _factories.get(name);
		}
		return null;
	}
}