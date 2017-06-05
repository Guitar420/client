// Copyright 2017 Keybase Inc. All rights reserved.
// Use of this source code is governed by a BSD
// license that can be found in the LICENSE file.

package libdokan

import (
	"github.com/keybase/kbfs/dokan"
	"golang.org/x/net/context"
)

type fakeRoot struct {
	EmptyFolder
}

func openFakeRoot(ctx context.Context, fs *FS, fi *dokan.FileInfo) (dokan.File, bool, error) {
	path := fi.Path()
	fs.log.CDebugf(ctx, "openFakeRoot %q", path)
	if path == `\`+WrongUserErrorDirName {
		return &EmptyFolder{}, true, nil
	}
	return &fakeRoot{}, true, nil
}

// FindFiles for dokan.
func (*fakeRoot) FindFiles(ctx context.Context, fi *dokan.FileInfo, ignored string, callback func(*dokan.NamedStat) error) (err error) {
	var ns dokan.NamedStat
	ns.FileAttributes = dokan.FileAttributeDirectory
	ns.Name = WrongUserErrorDirName
	return callback(&ns)
}
