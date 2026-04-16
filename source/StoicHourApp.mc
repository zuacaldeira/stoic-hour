using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Lang;

class StoicHourApp extends Application.AppBase {

    private var _view as StoicHourView?;

    function initialize() {
        AppBase.initialize();
        _view = null;
    }

    function onStart(state as Lang.Dictionary?) as Void {}

    function onStop(state as Lang.Dictionary?) as Void {}

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        _view = new StoicHourView();
        return [_view as WatchUi.Views];
    }

    function onSettingsChanged() as Void {
        if (_view != null) {
            _view.onSettingsChanged();
        }
        WatchUi.requestUpdate();
    }
}
