
#import "MonitoringSettingsWindowController.h"

#import "Preferences.h"
#import "RegexKitLite.h"


@interface MonitoringSettingsWindowController () <NSTableViewDataSource, NSTableViewDelegate>
@end



@implementation MonitoringSettingsWindowController

@synthesize builtInExtensionsLabelField=_builtInExtensionsLabelField;
@synthesize additionalExtensionsTextField = _additionalExtensionsTextField;
@synthesize disableLiveRefreshCheckBox = _disableLiveRefreshCheckBox;
@synthesize delayFullRefreshCheckBox = _delayFullRefreshCheckBox;
@synthesize fullRefreshDelayTextField = _fullRefreshDelayTextField;
@synthesize excludedPathsTableView = _excludedPathsTableView;

- (void)windowDidLoad {
    [super windowDidLoad];
}


#pragma mark - Actions

- (IBAction)showHelp:(id)sender {
    TenderShowArticle(@"");
}


#pragma mark - Model sync

- (void)renderFullPageRefreshDelay {
    if (_delayFullRefreshCheckBox.state == NSOnState) {
        _fullRefreshDelayTextField.stringValue = [NSString stringWithFormat:@"%.3f", _project.fullPageReloadDelay];
        [_fullRefreshDelayTextField setEnabled:YES];
    } else {
        _fullRefreshDelayTextField.stringValue = @"";
        [_fullRefreshDelayTextField setEnabled:NO];
    }
}

- (void)render {
    _builtInExtensionsLabelField.stringValue = [[[Preferences sharedPreferences].builtInExtensions sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@" "];
    _additionalExtensionsTextField.stringValue = [[Preferences sharedPreferences].additionalExtensions componentsJoinedByString:@" "];
    _disableLiveRefreshCheckBox.state = (_project.disableLiveRefresh ? NSOnState : NSOffState);
    _delayFullRefreshCheckBox.state = (_project.fullPageReloadDelay > 0.001 ? NSOnState : NSOffState);
    [self renderFullPageRefreshDelay];
}

- (void)save {
    NSString *extensions = [[_additionalExtensionsTextField.stringValue stringByReplacingOccurrencesOfRegex:@"[, ]+" withString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [Preferences sharedPreferences].additionalExtensions = (extensions.length > 0 ? [extensions componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : [NSArray array]);
    _project.fullPageReloadDelay = (_delayFullRefreshCheckBox.state == NSOnState ? _fullRefreshDelayTextField.doubleValue : 0.0);
}


#pragma mark - Interim actions

- (IBAction)disableLiveRefreshCheckBoxClicked:(NSButton *)sender {
    _project.disableLiveRefresh = (_disableLiveRefreshCheckBox.state == NSOnState);
}

- (IBAction)delayFullRefreshCheckBoxClicked:(id)sender {
    [self renderFullPageRefreshDelay];
}


#pragma mark - Excluded paths

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _project.excludedPaths.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [_project.excludedPaths objectAtIndex:row];
}

- (IBAction)addExcludedPathClicked:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:YES];
    [openPanel setPrompt:@"Choose a subfolder"];
    [openPanel setCanChooseFiles:NO];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:_project.path isDirectory:YES]];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = [openPanel URL];
            NSString *path = [url path];
            NSString *relativePath = [_project relativePathForPath:path];
            if (relativePath == nil) {
                [[NSAlert alertWithMessageText:@"Subfolder required" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Excluded folder must be a subfolder of the project."] runModal];
                return;
            }
            if (relativePath.length == 0) {
                [[NSAlert alertWithMessageText:@"Subfolder required" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Sorry, but excluding the project's root folder does not make sense."] runModal];
                return;
            }
            [_project addExcludedPath:relativePath];
            [_excludedPathsTableView reloadData];
        }
    }];
}

- (IBAction)removeExcludedPathClicked:(id)sender {
    NSInteger row = _excludedPathsTableView.selectedRow;
    if (row < 0)
        return;

    if (row >= _project.excludedPaths.count)
        return;

    NSString *path = [_project.excludedPaths objectAtIndex:row];
    [_project removeExcludedPath:path];
    [_excludedPathsTableView reloadData];

    [_excludedPathsTableView deselectAll:nil];
}

@end