// +build openbsd

package fsutil

func chtimes(path string, un int64) error {
	return nil
}
